{{/*
#============LICENSE_START========================================================
# ================================================================================
# Copyright (c) 2021 J. F. Lucas. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================
*/}}
{{/*
For internal use only!

dcaegen2-services-common._ms-specific-env-vars:
This template generates a list of microservice-specific environment variables
as specified in .Values.applicationEnv.  The
dcaegen2-services-common.microServiceDeployment uses this template
to add the microservice-specific environment variables to the microservice's container.
These environment variables are in addition to a standard set of environment variables
provided to all microservices.

The template expects a single argument, pointing to the caller's global context.

Microservice-specific environment variables can be specified in two ways:
  1. As literal string values.
  2. As values that are sourced from a secret, identified by the secret's
     uid and the key within the secret that provides the value.

The following example shows an example of each type.  The example assumes
that a secret has been created using the OOM common secret mechanism, with
a secret uid "example-secret" and a key called "password".

applicationEnv:
  APPLICATION_PASSWORD:
    secretUid: example-secret
    key: password
  APPLICATION_EXAMPLE: "An example value"

The example would set two environment variables on the microservice's container,
one called "APPLICATION_PASSWORD" with the value set from the "password" key in
the secret with uid "example-secret", and one called "APPLICATION_EXAMPLE" set to
the the literal string "An example value".
*/}}
{{- define "dcaegen2-services-common._ms-specific-env-vars" -}}
  {{- $global := . }}
  {{- if .Values.applicationEnv }}
    {{- range $envName, $envValue := .Values.applicationEnv }}
      {{- if kindIs "string" $envValue }}
- name: {{ $envName }}
  value: {{ $envValue | quote }}
      {{- else }}
        {{ if or (not $envValue.secretUid) (not $envValue.key) }}
          {{ fail (printf "Env %s definition is not a string and does not contain secretUid or key fields" $envName) }}
        {{- end }}
- name: {{ $envName }}
  {{- include "common.secret.envFromSecretFast" (dict "global" $global "uid" $envValue.secretUid "key" $envValue.key) | indent 2 }}
      {{- end -}}
    {{- end }}
  {{- end }}
{{- end -}}
{{/*
dcaegen2-services-common.microserviceDeployment:
This template produces a Kubernetes Deployment for a DCAE microservice.

All DCAE microservices currently use very similar Deployments.  Having a
common template eliminates a lot of repetition in the individual charts
for each microservice.

The template expects the full chart context as input.  A chart for a
DCAE microservice references this template using:
{{ include "dcaegen2-services-common.microserviceDeployment" . }}
The template directly references data in .Values, and indirectly (through its
use of templates from the ONAP "common" collection) references data in
.Release.

The exact content of the Deployment generated from this template
depends on the content of .Values.

The Deployment always includes a single Pod, with a container that uses
the DCAE microservice image.

The Deployment Pod may also include a logging sidecar container.
The sidecar is included if .Values.logDirectory is set.  The
logging sidecar and the DCAE microservice container share a
volume where the microservice logs are written.

The Deployment includes an initContainer that pushes the
microservice's initial configuration (from .Values.applicationConfig)
into Consul.  All DCAE microservices retrieve their initial
configurations by making an API call to a DCAE platform component called
the  config-binding-service.  The config-binding-service currently
retrieves configuration information from Consul.

The Deployment also includes an initContainer that checks for the
readiness of other components that the microservice relies on.
This container is generated by the "common.readinessCheck.waitfor"
template.

If the microservice acts as a TLS client or server, the Deployment will
include an initContainer that retrieves certificate information from
the AAF certificate manager.  The information is mounted at the
mount point specified in .Values.certDirectory.  If the microservice is
a TLS server (indicated by setting .Values.tlsServer to true), the
certificate information will include a server cert and key, in various
formats.  It will also include the AAF CA cert.   If the microservice is
a TLS client only (indicated by setting .Values.tlsServer to false), the
certificate information includes only the AAF CA cert.
*/}}

{{- define "dcaegen2-services-common.microserviceDeployment" -}}
{{- $logDir :=  default "" .Values.logDirectory -}}
{{- $certDir := default "" .Values.certDirectory . -}}
{{- $tlsServer := default "" .Values.tlsServer -}}
apiVersion: apps/v1
kind: Deployment
metadata: {{- include "common.resourceMetadata" . | nindent 2 }}
spec:
  replicas: 1
  selector: {{- include "common.selectors" . | nindent 4 }}
  template:
    metadata: {{- include "common.templateMetadata" . | nindent 6 }}
    spec:
      initContainers:
      - command:
        - sh
        args:
        - -c
        - |
        {{- range $var := .Values.customEnvVars }}
          export {{ $var.name }}="{{ $var.value }}";
        {{- end }}
          cd /config-input && for PFILE in `ls -1`; do envsubst <${PFILE} >/config/${PFILE}; done
        env:
        {{- range $cred := .Values.credentials }}
        - name: {{ $cred.name }}
          {{- include "common.secret.envFromSecretFast" (dict "global" $ "uid" $cred.uid "key" $cred.key) | indent 10 }}
        {{- end }}
        volumeMounts:
        - mountPath: /config-input
          name: app-config-input
        - mountPath: /config
          name: app-config
        image: {{ include "repositoryGenerator.image.envsubst" . }}
        imagePullPolicy: {{ .Values.global.pullPolicy | default .Values.pullPolicy }}
        name: {{ include "common.name" . }}-update-config

      {{ include "common.readinessCheck.waitFor" . | indent 6 | trim }}
      - name: init-consul
        image: {{ include "repositoryGenerator.repository" . }}/{{ .Values.consulLoaderImage }}
        imagePullPolicy: {{ .Values.global.pullPolicy | default .Values.pullPolicy }}
        args:
        - --key-yaml
        - "{{ include "common.name" . }}|/app-config/application_config.yaml"
        resources: {{ include "common.resources" . | nindent 2 }}
        volumeMounts:
          - mountPath: /app-config
            name: app-config
      {{- if $certDir }}
      - name: init-tls
        image: {{ include "repositoryGenerator.repository" . }}/{{ .Values.tlsImage }}
        imagePullPolicy: {{ .Values.global.pullPolicy | default .Values.pullPolicy }}
        env:
        - name: TLS_SERVER
          value: {{ $tlsServer | quote }}
        - name: POD_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.podIP
        resources: {{ include "common.resources" . | nindent 2 }}
        volumeMounts:
        - mountPath: /opt/app/osaaf
          name: tls-info
      {{- end }}
      containers:
      - image: {{ include "repositoryGenerator.repository" . }}/{{ .Values.image }}
        imagePullPolicy: {{ .Values.global.pullPolicy | default .Values.pullPolicy }}
        name: {{ include "common.name" . }}
        env:
        {{- if $certDir }}
        - name: DCAE_CA_CERTPATH
          value: {{ $certDir}}/cacert.pem
        {{- end }}
        - name: CONSUL_HOST
          value: consul-server.onap
        - name: CONFIG_BINDING_SERVICE
          value: config-binding-service
        - name: CBS_CONFIG_URL
          value: https://config-binding-service:10443/service_component_all/{{ include "common.name" . }}
        - name: POD_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.podIP
        {{- include "dcaegen2-services-common._ms-specific-env-vars" . | nindent 8 }}
        {{- if .Values.service }}
        ports: {{ include "common.containerPorts" . | nindent 10 }}
        {{- end }}
        {{- if .Values.readiness }}
        readinessProbe:
          initialDelaySeconds: {{ .Values.readiness.initialDelaySeconds | default 5 }}
          periodSeconds: {{ .Values.readiness.periodSeconds | default 15 }}
          timeoutSeconds: {{ .Values.readiness.timeoutSeconds | default 1 }}
          {{- $probeType := .Values.readiness.type | default "httpGet" -}}
          {{- if eq $probeType "httpGet" }}
          httpGet:
            scheme: {{ .Values.readiness.scheme }}
            path: {{ .Values.readiness.path }}
            port: {{ .Values.readiness.port }}
          {{- end }}
          {{- if eq $probeType "exec" }}
          exec:
            command:
            {{- range $cmd := .Values.readiness.command }}
            - {{ $cmd }}
            {{- end }}
          {{- end }}
        {{- end }}
        resources: {{ include "common.resources" . | nindent 2 }}
        {{- if or $logDir $certDir  }}
        volumeMounts:
        {{- if $logDir }}
        - mountPath: {{ $logDir}}
          name: component-log
        {{- end }}
        {{- if $certDir }}
        - mountPath: {{ $certDir }}
          name: tls-info
        {{- end }}
        {{- end }}
      {{- if $logDir }}
      - image: {{ include "repositoryGenerator.image.logging" . }}
        imagePullPolicy: {{ .Values.global.pullPolicy | default .Values.pullPolicy }}
        name: filebeat
        env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.podIP
        resources: {{ include "common.resources" . | nindent 2 }}
        volumeMounts:
        - mountPath: /var/log/onap/{{ include "common.name" . }}
          name: component-log
        - mountPath: /usr/share/filebeat/data
          name: filebeat-data
        - mountPath: /usr/share/filebeat/filebeat.yml
          name: filebeat-conf
          subPath: filebeat.yml
      {{- end }}
      hostname: {{ include "common.name" . }}
      volumes:
      - configMap:
          defaultMode: 420
          name: {{ include "common.fullname" . }}-application-config-configmap
        name: app-config-input
      - emptyDir:
          medium: Memory
        name: app-config
      {{- if $logDir }}
      - emptyDir: {}
        name: component-log
      - emptyDir: {}
        name: filebeat-data
      - configMap:
          defaultMode: 420
          name: {{ include "common.fullname" . }}-filebeat-configmap
        name: filebeat-conf
      {{- end }}
      {{- if $certDir }}
      - emptyDir: {}
        name: tls-info
      {{- end }}
      imagePullSecrets:
      - name: "{{ include "common.namespace" . }}-docker-registry-key"
{{ end -}}
