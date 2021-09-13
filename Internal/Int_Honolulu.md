# Int_Honolulu

## Table of contents

<!--ts-->
   * [Introduction](#Introduction)
   * [Creating an environment for OOM VM of HONOLULU release](#Creating-an-environment-for-OOM-VM-of-HONOLULU-release)
   * [Testing of tosca models in HONOLULU release](#Testing-of-tosca-models-in-HONOLULU-release)
   * [Post Deployment Verification Steps](#Post-Deployment-Verification-Steps)
<!--te-->

## Introduction
  
  This page describes steps that need to be followed to create the necessary environment for deploying tosca models using built-in workflow or argo-workflow. It also describes steps for building csars for various models currently available.
	
  For now, we can test argo workflow only in tosca components running in pods format in the OOM Honolulu environment.

## Creating an environment for OOM VM of HONOLULU release
  
  - **OOM DEMO Server**
	 
	- Create AWS VM in Ohio region with following specifications and SSH it using putty by using cciPrivateKey:
	  
	  ```sh
	  Name: ONAP_OOM_DEMO
	  Image: ubuntu-18.04
	  InstanceType: m5a.4xlarge
	  Storage: 100GB
	  KeyPair : cciPublicKey
	  Security group: launch-wizard-19
	  ```
	  
    - Setup Docker:
	
	  ```sh
	  $ sudo apt update
	  $ sudo apt install apt-transport-https ca-certificates curl software-properties-common
	  $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
	  $ sudo apt update
	  $ apt-cache policy docker-ce
	  $ sudo apt-get install containerd.io docker-ce=5:19.03.5~3-0~ubuntu-bionic docker-ce-cli=5:19.03.5~3-0~ubuntu-bionic
	  $ sudo usermod -aG docker ${USER}
	  $ id -nG
	  $ cd //
	  $ sudo chmod -R 777 /etc/docker
	
      # Create a file named daemon.json in /etc/docker and add the following content to it.
		  { "insecure-registries":["172.31.27.186:5000"] }
		  
	  $ sudo systemctl stop docker 
	  $ sudo systemctl start docker
	  $ sudo chmod 777 /var/run/docker.sock
	  ```
	  
	  Note: 172.31.27.186 is the private IP address of CCI_REPO VM.
		
	- Setup kubectl:
	  
	  ```sh
	  $ cd /home/ubuntu/
	  $ curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.9/bin/linux/amd64/kubectl
	  $ sudo chmod +x ./kubectl
	  $ sudo mv ./kubectl /usr/local/bin/kubectl
	  $ grep -E --color 'vmx|svm' /proc/cpuinfo
      ```
	  
	- Setup minikube:
	
	  ```sh
	  $ sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	  $ sudo chmod +x minikube
	  $ sudo mv ./minikube /usr/local/bin/minikube
	  $ sudo apt-get install conntrack
	  $ sudo minikube start --driver=none --kubernetes-version 1.19.9
	  $ sudo mv /home/ubuntu/.kube /home/ubuntu/.minikube $HOME
	  $ sudo chown -R $USER $HOME/.kube $HOME/.minikube
	  $ kubectl get pods -n onap -o=wide
	  ```

	- Clone repo:
	
	  ```sh
	  $ git clone https://github.com/customercaresolutions/onap-oom-integ.git -b honolulu --recurse-submodules
	  ```

	- Install helm:
	  
	  ```sh
	  $ wget https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz
	  $ tar xvfz helm-v3.5.2-linux-amd64.tar.gz
	  $ sudo mv linux-amd64/helm /usr/local/bin/helm
	  ```
		
	- Setup helm:
	
	  ```sh
	  $ sudo mkdir ~/.local
	  $ sudo mkdir ~/.local/share
	  $ sudo mkdir ~/.local/share/helm
	  $ sudo cp -R ~/onap-oom-integ/kubernetes/helm/plugins/ ~/.local/share/helm/plugins
	  $ sudo chmod -R 777 /home/ubuntu/.local
	  $ helm plugin install https://github.com/chartmuseum/helm-push.git
      ```
	  
	- Setup chartmuseum:
		
	  ```sh	
	  $ curl -LO https://s3.amazonaws.com/chartmuseum/release/latest/bin/linux/amd64/chartmuseum
	  $ chmod +x ./chartmuseum
	  $ sudo mv ./chartmuseum /usr/local/bin
	  $ chartmuseum --storage local --storage-local-rootdir ~/helm3-storage -port 8879 &
	  $ helm repo add local http://127.0.0.1:8879
	  $ helm repo list
	  $ sudo apt install make
	  $ sudo chmod 777 /var/run/docker.sock
	  ```
	  
	  Note: After running "chartmuseum --storage local --storage-local-rootdir ~/helm3-storage -port 8879 &" this command we have to press enter and go ahead.
	
    - Create oran setup(optional):
	  
	  Create oran setup when need to deploy oran models otherwise no need to set up them for sdwan and firewall models.
	  
	  GIN can deploy the tosca models using two ways.
	  
      - Built-in(puccini) workflow:
	     
		To create oran setup for built-in(puccini) workflow use the GIN_README as follows:
		
		[ORAN-Servers](https://github.com/rajeshvkothari3003/oom/blob/master/GIN_README_2508.md#ORAN-Servers)
	  
	  - Argo-workflow:
	    
		To create oran setup for argo-workflow use the steps as follows:
	  
	    - Create two AWS VMs in the Ohio region with names as follows:
		
		  ```sh
		  VM1 Name: ric Server
		  VM2 Name: nonrtric Server
		  ```
				
	    - And use the following specifications and SSH it using putty by using cciPrivateKey:
		  
		  ```sh
		  Image: ubuntu-18.04
		  InstanceTye: t2.2xlarge
		  KeyPair : cciPublicKey
		  Disk: 80GB
		  Security group: launch-wizard-19
		  ```
				   
	    - Login into ric server and nonrtric server and run the following commands:
		  
		  ```sh
		  $ sudo apt update
		  $ sudo apt install jq
		  $ sudo apt install socat
		  $ sudo mkdir -p /etc/rancher/k3s
          $ sudo chmod -R 777 /etc/rancher/k3s
		
		  # Create a file named registries.yaml on this (/etc/rancher/k3s/) location and add the following content to it.
		  mirrors:
             "172.31.27.186:5000":
                endpoint:
                   - "http://172.31.27.186:5000"
		  ```
		  IMP Note: Above YAML must be in a valid format. also, check whether proper indentation is used.

		  To know more about valid YAML format use below link: 

		  ```sh
		  https://jsonformatter.org/yaml-validator
		  ```
		  
    - Make the changes as per the requirement in the ~/onap-oom-integ/cci/application.cfg: 
	  
	  - For built-in(puccini) workflow:
	    
		```sh
		[remote]
		remoteHost={IP_ADDR_OF_SERVER}
		remotePort=22
		remoteUser=ubuntu
		remotePubKey=/opt/app/config/cciPrivateKey
		workflowType=puccini-workflow
		```
		
		Note: {IP_OF_SERVER_ADDR} should be set to {IP_OF_ONAP_OOM_DEMO_ADDR} for deploying sdwan, firewall. In the case of oran models, it should be set to {IP_ADDR_OF_BONAP_SERVER}.
				
      - For argo-workflow:

		```sh
		remoteHost={IP_ADDR_OF_ONAP_OOM_DEMO}
		reposureHost={IP_ADDR_OF_ONAP_OOM_DEMO}
		ricServerIP={IP_ADDR_OF_RIC}
		nonrtricServerIP={IP_ADDR_OF_NONRTRIC}
		workflowType=argo-workflow
		argoTemplateType=containerSet
        ```		
		
		Note: To deploy a firewall and sdwan models only add {IP_ADDR_OF_ONAP_OOM_DEMO} and for oran, models add all IPs.
		
		In argo workflow, there are two ways for executing argo templates.
		
        - containerSet: A containerSet template is similar to a normal container or script template but allows you to specify multiple containers to run within a single pod.
				
	      - For using containerSet based argo template set:
	    
		    ```sh
		    argoTemplateType=containerSet
		    ```
			
        - DAG: DAG (Directed Acyclic Graph) contains a set of steps (nodes) and the dependencies (edges) between them.
				
	      - For using DAG-based argo template set:
		
		    ```sh	
		    argoTemplateType=DAG
		    ```
		
    - Install golang:
	  
	  ```sh
	  $ /home/ubuntu
	  $ sudo curl -O https://storage.googleapis.com/golang/go1.17.linux-amd64.tar.gz
	  $ sudo tar -xvf go1.17.linux-amd64.tar.gz
	  $ sudo mv go /usr/local
	  
      # Add following paths in .profile file: 
      $ sudo vi ~/.profile
		  export GOPATH=$HOME/go
		  export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

	  $ source ~/.profile
	  $ go version
      ```

    - Setup reposure:
	
	  ```sh
	  $ cd /home/ubuntu
	  $ git clone https://github.com/tliron/reposure -b v0.1.6
	
	  $ vi reposure/reposure/commands/registry-create.go	
	  # for insecure installation, commented out the section in reposure/reposure/commands/registry-create.go, as follows:
		if authenticationSecret == "" {
		//authenticationSecret = "reposure-simple-authentication"
		}

	  $ cd reposure/scripts
	  $ ./build
	  $ cd /home/ubuntu
	  $ reposure operator install --wait	
	  $ reposure simple install --wait
	  $ reposure registry create default  --provider=simple --wait -v
	  ```	

	- Setup ARGO:
	  
	  ```sh
	  $ kubectl create ns onap
	  
	  # For containerSet use following command:
	  $ sudo kubectl apply -n onap -f /home/ubuntu/onap-oom-integ/argo-config/workflow-controller-configmap.yaml 
	  
	  # For DAG use following command:
	  $ sudo kubectl apply -n onap -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/namespace-install.yaml 
	  
	  $ curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.1.1/argo-linux-amd64.gz
	  $ gunzip argo-linux-amd64.gz
	  $ chmod +x argo-linux-amd64
	  $ sudo mv ./argo-linux-amd64 /usr/local/bin/argo
	  $ argo version
	  ```
		
	- Build charts:
	  
	  ```sh
	  $ cd ~/onap-oom-integ/kubernetes
	  $ make SKIP_LINT=TRUE all; make SKIP_LINT=TRUE onap
	  $ helm repo update
	  $ helm search repo onap
	  ```
	
	- Verify that CCI_REPO VM on Ohio region is in running state. If it is not running then go to AWS and start it.

	- Deploy ONAP:
		
	  ```sh
	  $ cd ~/onap-oom-integ/kubernetes
	  $ helm deploy onap local/onap --namespace onap --create-namespace --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 1500s
      ```
	  
	  This step requires around 25-30 min to deploy ONAP.
	  
	- To verify that ONAP is deployed successfully, use the following command and check that all pods are in running state:

      ```sh
	  $ kubectl get pods -n onap
	  
	  ubuntu@ip-172-31-38-49:~$ kubectl get pods -n onap
	  NAME                                           READY   STATUS             RESTARTS   AGE
	  argo-server-576b68c7cf-ttq8m                   1/1     Running            2          76m
	  minio-58977b4b48-wnl6c                         1/1     Running            0          76m
	  onap-aaf-cass-54c568c8cf-zhfsw                 1/1     Running            0          22m
	  onap-aaf-cm-8649d449f6-wz66c                   1/1     Running            0          22m
  	  onap-aaf-fs-5864f44d-cmvbc                     1/1     Running            0          22m
	  onap-aaf-gui-7496fcc766-x8r8m                  1/1     Running            0          22m
	  onap-aaf-locate-5c64459758-l87c7               1/1     Running            0          22m
	  onap-aaf-oauth-588658b9dd-wcfp2                1/1     Running            0          22m
	  onap-aaf-service-78579cb56f-p5rln              1/1     Running            0          22m
	  onap-aaf-sms-5b45b944d9-rzzfv                  1/1     Running            0          22m
	  onap-aaf-sms-preload-9wml6                     0/1     Completed          0          22m
	  onap-aaf-sms-quorumclient-0                    1/1     Running            0          22m
	  onap-aaf-sms-quorumclient-1                    1/1     Running            0          22m
	  onap-aaf-sms-quorumclient-2                    1/1     Running            0          21m
	  onap-aaf-sms-vault-0                           2/2     Running            0          22m
	  onap-aaf-sshsm-distcenter-r9tbb                0/1     Completed          0          22m
	  onap-aaf-sshsm-testca-mjqxt                    0/1     Completed          0          22m
	  onap-aai-58c68fb8fc-hjx2w                      1/1     Running            0          22m
	  onap-aai-babel-d6d9b588-2nrx2                  2/2     Running            0          22m
	  onap-aai-graphadmin-6d8c65bccf-48szt           2/2     Running            0          22m
	  onap-aai-graphadmin-create-db-schema-qt8gg     0/1     Completed          0          22m
	  onap-aai-modelloader-857d4697b-5wh2j           2/2     Running            0          22m
	  onap-aai-resources-5857bf6bb8-bqwrv            2/2     Running            0          22m
	  onap-aai-schema-service-7c5d56d55-hqqfd        2/2     Running            0          22m
	  onap-aai-sparky-be-55db5b5d74-tpst8            2/2     Running            0          22m
	  onap-aai-traversal-759cc5c867-zzzb6            2/2     Running            0          22m
	  onap-aai-traversal-update-query-data-f6vk5     0/1     Completed          0          22m
	  onap-awx-0                                     1/4     ImagePullBackOff   0          21m
	  onap-awx-postgres-66886c8994-lwg6v             1/1     Running            0          21m
	  onap-awx-qc9bs                                 0/1     Completed          0          21m
	  onap-cassandra-0                               1/1     Running            0          22m
	  onap-cassandra-1                               1/1     Running            0          18m
	  onap-cassandra-2                               1/1     Running            0          14m
	  onap-dbc-pg-primary-78585f6b7-4jx4k            1/1     Running            0          20m
	  onap-dbc-pg-replica-58ff5d98dc-vd8cf           1/1     Running            0          20m
	  onap-dmaap-bc-76bb577d58-bgxnv                 1/1     Running            0          20m
	  onap-dmaap-bc-dmaap-provisioning-2qjml         0/1     Init:Error         0          20m
	  onap-dmaap-bc-dmaap-provisioning-rccc4         0/1     Completed          0          10m
	  onap-dmaap-dr-db-0                             2/2     Running            0          20m
	  onap-dmaap-dr-node-0                           2/2     Running            0          20m
	  onap-dmaap-dr-prov-6f7465bbc6-kc2r5            2/2     Running            0          20m
	  onap-ejbca-ccb7b44c6-r8l2r                     1/1     Running            0          21m
	  onap-ejbca-config-config-job-nqq25             0/1     Completed          0          10m
	  onap-ejbca-config-config-job-vbddf             0/1     Init:Error         0          21m
	  onap-mariadb-galera-0                          2/2     Running            0          20m
	  onap-mariadb-galera-1                          2/2     Running            0          16m
	  onap-mariadb-galera-2                          2/2     Running            0          8m11s
	  onap-message-router-0                          1/1     Running            0          20m
	  onap-message-router-kafka-0                    1/1     Running            0          20m
	  onap-message-router-kafka-1                    1/1     Running            0          20m
	  onap-message-router-kafka-2                    1/1     Running            0          20m
	  onap-message-router-zookeeper-0                1/1     Running            0          20m
	  onap-message-router-zookeeper-1                1/1     Running            0          20m
	  onap-message-router-zookeeper-2                1/1     Running            0          20m
	  onap-netbox-app-674f9d5f-krgrt                 1/1     Running            1          21m
	  onap-netbox-app-provisioning-lj5dv             0/1     ImagePullBackOff   0          21m
	  onap-netbox-nginx-76464b784-psjjz              1/1     Running            0          21m
	  onap-netbox-postgres-594f478d68-wvgjv          1/1     Running            0          21m
	  onap-portal-app-964f7cf5-jt8xg                 2/2     Running            0          20m
	  onap-portal-cassandra-dd4fc76b7-m8m8z          1/1     Running            0          20m
	  onap-portal-db-5d4db9d8dd-4ggtp                1/1     Running            0          20m
	  onap-portal-db-config-tf28x                    0/2     Completed          0          20m
	  onap-portal-sdk-644d7bfdfd-bvvbr               2/2     Running            0          20m
	  onap-portal-widget-5fcb9c4d89-rzdvd            1/1     Running            0          20m
	  onap-robot-7f59bd9f97-hbc58                    1/1     Running            0          20m
	  onap-sdc-be-558b4d86cf-d5mn2                   1/2     Running            0          20m
	  onap-sdc-be-config-backend-m7wxd               0/1     Init:0/1           0          20m
	  onap-sdc-cs-config-cassandra-6w9vl             0/1     Completed          0          20m
	  onap-sdc-fe-679bc6f44d-8tvq6                   0/2     Init:2/4           0          20m
	  onap-sdc-onboarding-be-78d5d955b4-czl4g        2/2     Running            0          20m
	  onap-sdc-onboarding-be-cassandra-init-l7vsn    0/1     Completed          0          20m
	  onap-sdc-wfd-be-7956d95666-q8f8c               1/1     Running            0          20m
	  onap-sdc-wfd-be-workflow-init-4wlcx            0/1     Completed          0          20m
	  onap-sdc-wfd-fe-76c94bc665-2hwq4               2/2     Running            0          20m
	  onap-so-5d48886cb8-r8bbf                       2/2     Running            0          8m53s
	  onap-so-admin-cockpit-584d586894-sqt8v         1/1     Running            0          8m52s
	  onap-so-bpmn-infra-7868f977d4-2ctd6            2/2     Running            0          8m53s
	  onap-so-catalog-db-adapter-5bdd4f7ff-9h594     1/1     Running            0          8m53s
	  onap-so-cnf-adapter-5bfbd6486b-jmzxf           1/1     Running            0          8m52s
	  onap-so-etsi-nfvo-ns-lcm-59f455d7b-4fjwf       1/1     Running            4          8m53s
	  onap-so-etsi-sol003-adapter-794d599bbb-9m5gx   1/1     Running            0          8m53s
	  onap-so-etsi-sol005-adapter-698447dc8b-wjtnp   1/1     Running            0          8m53s
	  onap-so-mariadb-config-job-nvtgz               0/1     Completed          0          8m52s
	  onap-so-nssmf-adapter-7687766f-l2vk7           1/1     Running            0          8m53s
	  onap-so-oof-adapter-847bf7f67f-9rdvv           2/2     Running            0          8m53s
	  onap-so-openstack-adapter-56fb87f5d9-lwwcr     2/2     Running            0          8m53s
	  onap-so-request-db-adapter-666fdf8f7f-fssv9    1/1     Running            0          8m52s
	  onap-so-sdc-controller-856b9596c-f9qtb         2/2     Running            0          8m52s
	  onap-so-sdnc-adapter-fb94764c8-5qdgq           2/2     Running            0          8m53s
	  onap-tosca-858768ff5b-gzx4t                    2/2     Running            0          4m29s
	  onap-tosca-compiler-6c58c67657-gcv7x           2/2     Running            0          4m29s
	  onap-tosca-dgraph-56cdf6ddd9-z2zrk             2/2     Running            0          4m29s
	  onap-tosca-gawp-684d7b8544-n88k5               2/2     Running            0          4m29s
	  onap-tosca-policy-7754748966-q9j6v             2/2     Running            0          4m29s
	  onap-tosca-workflow-76445fb68-7rz6x            2/2     Running            0          4m29s
	  onap-vid-7b5c7f48f9-mwjwj                      2/2     Running            0          4m25s
	  onap-vid-mariadb-init-config-job-z8xd2         0/1     Completed          0          4m25s
	  postgres-6b5c55f477-lkrml                      1/1     Running            0          76m
	  workflow-controller-6587f8545-dzx9d            1/1     Running            2          76m
	  ```
	
	- Copy latest models csars to ~/onap-oom-integ/cci directory in ONAP_OOM_DEMO VM.

## Testing of tosca models in HONOLULU release

  Currently, testing of tosca models in Honolulu is done using REST API requests sent from POSTMAN. These requests and their order is described as follows.

- Store models in Dgraph:
    
  ```sh
  POST http://{IP_ADDR_OF_ONAP_OOM_DEMO}:30294/compiler/model/db/save
  {
	 "url":"/opt/app/config/<MODEL_NAME>.csar",
	 "output": "./<MO>-dgraph-clout.json",
	 "resolve":true,
	 "coerce":false,
	 "quirks": ["data_types.string.permissive"],
	 "inputsUrl": ""
  }
  ```
	
  For all models except the ric model use following model-specific additional fields:
	
  ```sh
  {
	 "inputs":"",
	 "url":"/opt/app/models/sdwan.csar",
	 "output": "./sdwan-dgraph-clout.json",
  }
  ```
	
  Use similar pattern for firewall, nonrtric, qp, qp-driver, ts models(means change only csar name).
	  
  For ric model use following model-specific additional fields:
	  
  ```sh
  { 
     "inputs":{"helm_version":"2.17.0"},
     "url":"/opt/app/models/ric.csar",
     "output": "./ric-dgraph-clout.json",
  }
  ```
	
- Create service instance:
	
  For sdwan, firewall, nonrtric, ric, qp, qp-driver, ts:
	
  ```sh			
  POST http://{IP_ADDR_OF_ONAP_OOM_DEMO}:30280/bonap/templates/createInstance
  {
	 "name":"<INSTANCE_NAME>",
	 "output":"./<MODEL_NAME>.json",
	 "list-steps-only":false,
	 "generate-workflow":false,
	 "execute-workflow":false,
	 "execute-policy":false
  }
  ```	
	  
  Use following model-specific additional fields:

    **Firewall:**  
	```sh
	  "inputs":"",
      "service":"zip:/opt/app/config/firewall.csar!/firewall/firewall_service.yaml",
      "inputsUrl":"zip:/opt/app/config/firewall.csar!/firewall/inputs/aws.yaml",
	```
	  
	**Sdwan:**
	```sh
	  "inputs":"",
	  "service":"zip:/opt/app/config/sdwan.csar!/sdwan/sdwan_service.yaml",
	  "inputsUrl":"zip:/opt/app/config/sdwan.csar!/sdwan/inputs/aws.yaml",
	```
	  
	**Ric:**
	```sh
	  "inputs":{"helm_version":"2.17.0"},
      "inputsUrl":"",
      "service":"zip:/opt/app/config/ric.csar!/ric.yaml"
	```	
	  
	**Nonrtric:**
	```sh
	  "inputs":"",
      "inputsUrl":"",
      "service":"zip:/opt/app/config/nonrtric.csar!/nonrtric.yaml"    
	```
	  
	**Qp:**
	```sh
	  "inputs":"",
      "inputsUrl":"",
      "service":"zip:/opt/app/config/qp.csar!/qp.yaml"
	```
	 
	**Qp-driver:**
	```sh
	  "inputs":"",
      "inputsUrl":"",
      "service":"zip:/opt/app/config/qp-driver.csar!/qp-driver.yaml"      
	```
	 
	**Ts:**
	```sh
	  "inputs":"",
      "inputsUrl":"",
      "service":"zip:/opt/app/config/ts.csar!/ts.yaml"
	```

- To deploy models:
  
  Use following API for all the models only replace the {INSTANCE_NAME} which we used in the create instance step
    
  ```sh
  http://{IP_ADDR_OF_ONAP_OOM_DEMO}:30280/bonap/templates/{INSTANCE_NAME}/workflows/deploy
  {
	 "list-steps-only": false,
	 "execute-policy": false
  }
  ```
  
  Note: If nonrtric model failed to deploy then check whether k3s is installed properly or not by running the following command on ric and nonrtric VM:
  
  ```sh
  $ journalctl -xe
  
  ubuntu@ip-172-31-21-29:~$ journalctl -xe
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.347968   29192 plugins.go:161] Loaded 10 validating admission controller(s) successfully in the following ord
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.348993   29192 plugins.go:158] Loaded 12 mutating admission controller(s) successfully in the following order
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.349018   29192 plugins.go:161] Loaded 10 validating admission controller(s) successfully in the following ord
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.366652   29192 master.go:271] Using reconciler: lease
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.777399   29192 genericapiserver.go:418] Skipping API batch/v2alpha1 because it has no resources.
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.795932   29192 genericapiserver.go:418] Skipping API discovery.k8s.io/v1alpha1 because it has no resources.
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.816518   29192 genericapiserver.go:418] Skipping API node.k8s.io/v1alpha1 because it has no resources.
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.847037   29192 genericapiserver.go:418] Skipping API rbac.authorization.k8s.io/v1alpha1 because it has no res
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.851495   29192 genericapiserver.go:418] Skipping API scheduling.k8s.io/v1alpha1 because it has no resources.
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.869121   29192 genericapiserver.go:418] Skipping API storage.k8s.io/v1alpha1 because it has no resources.
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.890727   29192 genericapiserver.go:418] Skipping API apps/v1beta2 because it has no resources.
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: W0910 06:18:44.890752   29192 genericapiserver.go:418] Skipping API apps/v1beta1 because it has no resources.
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.902722   29192 plugins.go:158] Loaded 12 mutating admission controller(s) successfully in the following order
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.902746   29192 plugins.go:161] Loaded 10 validating admission controller(s) successfully in the following ord
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.915795643Z" level=info msg="Running kube-scheduler --address=127.0.0.1 --bind-address=127.0.0.1 --
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.915967145Z" level=info msg="Waiting for API server to become available"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.916062   29192 registry.go:173] Registering SelectorSpread plugin
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: I0910 06:18:44.916077   29192 registry.go:173] Registering SelectorSpread plugin
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.916406959Z" level=info msg="Running kube-controller-manager --address=127.0.0.1 --allocate-node-ci
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.917797965Z" level=info msg="Node token is available at /var/lib/rancher/k3s/server/token"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.917846043Z" level=info msg="To join node to cluster: k3s agent -s https://172.31.21.29:6443 -t ${N
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.918716760Z" level=info msg="Wrote kubeconfig /etc/rancher/k3s/k3s.yaml"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.918753818Z" level=info msg="Run: k3s kubectl"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.946803448Z" level=info msg="Cluster-Http-Server 2021/09/10 06:18:44 http: TLS handshake error from
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.950787677Z" level=info msg="Cluster-Http-Server 2021/09/10 06:18:44 http: TLS handshake error from
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.960206765Z" level=info msg="certificate CN=ip-172-31-21-29 signed by CN=k3s-server-ca@1631253391:
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.962751749Z" level=info msg="certificate CN=system:node:ip-172-31-21-29,O=system:nodes signed by CN
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.967411013Z" level=info msg="Module overlay was already loaded"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.967442354Z" level=info msg="Module nf_conntrack was already loaded"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.967454400Z" level=info msg="Module br_netfilter was already loaded"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.967464422Z" level=info msg="Module iptable_nat was already loaded"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.973067751Z" level=info msg="Using registry config file at /etc/rancher/k3s/registries.yaml"
  Sep 10 06:18:44 ip-172-31-21-29 k3s[29192]: time="2021-09-10T06:18:44.973136323Z" level=fatal msg="yaml: line 3: found character that cannot start any token"
  Sep 10 06:18:44 ip-172-31-21-29 systemd[1]: k3s.service: Main process exited, code=exited, status=1/FAILURE
  Sep 10 06:18:44 ip-172-31-21-29 systemd[1]: k3s.service: Failed with result 'exit-code'.
  Sep 10 06:18:44 ip-172-31-21-29 systemd[1]: Failed to start Lightweight Kubernetes.
  -- Subject: Unit k3s.service has failed
  -- Defined-By: systemd
  -- Support: http://www.ubuntu.com/support
  --
  -- Unit k3s.service has failed.
  ```
  
  Also, check registries.yaml whether it contains the valid YAML format or not. if not then validate that YAML format and run the command as follows:
  
  ```sh
  $ sudo systemctl restart k3s
  ```
  
  After running the restart command try to deploy the nonrtric server again. 

## Post Deployment Verification Steps 
 
  Use following steps to verify models are deployed successfully. 
  
- Verify sdwan model:  
 
  - Verify {SERVICE_INSTANCE_NAME}_SDWAN_Site_A and {SERVICE_INSTANCE_NAME}_SDWAN_Site_B VMs should be created on AWS N.California region.
  - SSH SDWAN_Site_A VM and run the following command:
    
	```sh
	$ ifconfig -a
	```
	TODO:
    Ping WAN Public IP, LAN Private IP(vvp1), and VxLAN IP(vpp2) of SDWAN_Site_B.
	
  - SSH SDWAN_Site_B VM and run the following command:
    
	```sh
	$ ifconfig -a
	```
	Ping WAN Public IP, LAN Private IP(vvp1), and VxLAN IP(vvp2) of SDWAN_Site_A.
	
- Verify firewall model:

  - Verify TODO{SERVICE_INSTANCE_NAME}_firewall, {SERVICE_INSTANCE_NAME}_packet_genrator and {SERVICE_INSTANCE_NAME}_packet_sink VMs are created on AWS N.Virginia region.

- Verify nonrtric model:
	
  - Verify that all pods are running using the following command on a nonrtric server: 
    ```sh
	$ sudo kubectl get pods -n nonrtric
	
	ubuntu@ip-172-31-26-20:~$ sudo kubectl get pods -n nonrtric
	NAME                                       READY   STATUS    RESTARTS   AGE
	db-5d6d996454-xmfdn                        1/1     Running   0          7m15s
	a1-sim-std-0                               1/1     Running   0          7m15s
	controlpanel-fbf9d64b6-xsrv4               1/1     Running   0          7m15s
	enrichmentservice-5fd94b6d95-2dt2h         1/1     Running   0          7m15s
	rappcatalogueservice-64495fcc8f-njgpl      1/1     Running   0          7m15s
	policymanagementservice-78f6b4549f-sk7gd   1/1     Running   0          7m15s
	a1-sim-osc-0                               1/1     Running   0          7m15s
	a1-sim-std-1                               1/1     Running   0          6m3s
	a1-sim-osc-1                               1/1     Running   0          5m58s
	a1controller-cb6d7f6b8-tkql7               1/1     Running   0          7m15s
	``` 
	
- Verify ric model:

  - Verify all pods are running using the following commands on the ric server:
	```sh		
	$ sudo kubectl get pods -n ricplt
	$ sudo kubectl get pods -n ricinfra
	$ sudo kubectl get pods -n ricxapp 

	ubuntu@ip-172-31-21-29:~$ sudo kubectl get pods -n ricplt
	NAME                                                        READY   STATUS    RESTARTS   AGE
	statefulset-ricplt-dbaas-server-0                           1/1     Running   0          14m
	deployment-ricplt-jaegeradapter-5444d6668b-s6xm8            1/1     Running   0          14m
	deployment-ricplt-xapp-onboarder-f564f96dd-znlp5            2/2     Running   0          14m
	deployment-ricplt-vespamgr-54d75fc6d6-bxr7w                 1/1     Running   0          14m
	deployment-ricplt-alarmmanager-5f656dd7f8-fws8b             1/1     Running   0          14m
	r4-infrastructure-prometheus-alertmanager-98b79ccf7-n7zvs   2/2     Running   0          14m
	deployment-ricplt-e2mgr-7984fcdcb5-r5crh                    1/1     Running   0          14m
	deployment-ricplt-o1mediator-7b4c8547bc-nj5r2               1/1     Running   0          14m
	deployment-ricplt-e2term-alpha-6c85bcf675-vg7q8             0/1     Running   0          14m
	r4-infrastructure-kong-7bc786495-qdfnj                      2/2     Running   1          14m
	deployment-ricplt-a1mediator-68f8677df4-dnnbx               1/1     Running   0          14m
	r4-infrastructure-prometheus-server-dfd5c6cbb-5pcgs         1/1     Running   0          14m
	deployment-ricplt-submgr-5499794897-bzltn                   1/1     Running   0          14m
	deployment-ricplt-appmgr-5b94d9f97-pz5wr                    1/1     Running   0          12m
	deployment-ricplt-rtmgr-768655fc98-wvvrn                    1/1     Running   2          14m
	
	ubuntu@ip-172-31-21-29:~$ sudo  kubectl get pods -n ricinfra
	NAME                                         READY   STATUS      RESTARTS   AGE
	tiller-secret-generator-chglk                0/1     Completed   0          14m
	deployment-tiller-ricxapp-6895d7fd94-msmxs   1/1     Running     0          14m
	
	ubuntu@ip-172-31-21-29:~$ sudo kubectl get pods -n ricxapp
	No resources found in ricxapp namespace.
	```		

- Verify qp model:

  - Login 'ONAP_OOM_DEMO' and run the following commands:
    ```sh
    $ cd ~/
	$ argo list -n onap | grep qp
	$ docker ps -a | grep {ID_OF_QP_ARGO}
	$ docker cp {DOCKER_ID_OF_MAIN_CONTAINER}:/tmp/xapp.log /home/ubunut/qp_xapp.log
	
	# e.g. 
	  ubuntu@ip-172-31-27-243:~$ cd ~/
	  ubuntu@ip-172-31-27-243:~$ argo list -n onap | grep qp
	  qp1pq8kc             Succeeded   1h    20s        1

	  ubuntu@ip-172-31-27-243:~$ docker ps -a | grep qp1pq8kc
	  f1bc78609f02        449444000066                                       "/var/run/argo/argoe…"    About an hour ago   Exited (0) About an hour ago    k8s_main_qp1pq8kc_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

	  docker cp f1bc78609f02:/tmp/xapp.log /home/ubunut/qp_xapp.log
    
	# To check qp models deploy successfully, verify the following messages in /home/ubunut/qp_xapp.log.
    *         ric       ric       ric        
	Found RIC_HOST = 18.118.55.192
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									 Dload  Upload   Total   Spent    Left  Speed

	  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
	100   529  100    28  100   501    142   2543 --:--:-- --:--:-- --:--:--  2685
	{
		"status": "Created"
	}
	*         ric       ric       ric        
	Found RIC_HOST = 18.118.55.192
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									 Dload  Upload   Total   Spent    Left  Speed

	  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
	100    18    0     0  100    18      0     90 --:--:-- --:--:-- --:--:--    89
	100    18    0     0  100    18      0     14  0:00:01  0:00:01 --:--:--    14
	100    85  100    67  100    18     45     12  0:00:01  0:00:01 --:--:--    57
	{"instances":null,"name":"qp","status":"deployed","version":"1.0"}
    ```	  

- Verify qp-driver model:

  - Login 'ONAP_OOM_DEMO' and run the following commands:
    ```sh
    $ cd ~/
	$ argo list -n onap | grep qp-driver
	$ docker ps -a | grep {ID_OF_QP-deriver_ARGO}
	$ docker cp {DOCKER_ID_OF_MAIN_CONTAINER}:/tmp/xapp.log /home/ubunut/qp-driver_xapp.log
	
	# e.g. 
	  ubuntu@ip-172-31-27-243:~$ cd ~/
	  ubuntu@ip-172-31-27-243:~$ argo list -n onap | grep qp-driver
	  qp-deriver4rq2ws             Succeeded   1h    30m        1

	  ubuntu@ip-172-31-27-243:~$ docker ps -a | grep qp-deriver4rq2ws
	  u1ft76609r05        689546000088                                       "/var/run/argo/argoe…"    About an hour ago   Exited (0) About an hour ago    k8s_main_qp-deriver4rq2ws_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

	  docker cp u1ft76609r05:/tmp/xapp.log /home/ubunut/qp-driver_xapp.log
    
	# To check qp-driver models deploy successfully, verify the following messages in /home/ubunut/qp-driver_xapp.log.
    *         ric       ric       ric        
	Found RIC_HOST = 18.118.55.192
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									 Dload  Upload   Total   Spent    Left  Speed

	  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
	100  1160  100    28  100  1132    147   5957 --:--:-- --:--:-- --:--:--  6105
	{
		"status": "Created"
	}
	*         ric       ric       ric        
	Found RIC_HOST = 18.118.55.192
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									 Dload  Upload   Total   Spent    Left  Speed
									 
	  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
	100    97  100    73  100    24    102     33 --:--:-- --:--:-- --:--:--   136
	100    97  100    73  100    24    102     33 --:--:-- --:--:-- --:--:--   136
	{"instances":null,"name":"qpdriver","status":"deployed","version":"1.0"}
    ``` 

- Verify ts model:

  - Login 'ONAP_OOM_DEMO' and run the following commands:
    ```sh
    $ cd ~/
	$ argo list -n onap | grep ts
	$ docker ps -a | grep {ID_OF_TS_ARGO}
	$ docker cp {DOCKER_ID_OF_MAIN_CONTAINER}:/tmp/xapp.log /home/ubunut/ts_xapp.log
	
	# e.g. 
	  ubuntu@ip-172-31-27-243:~$ cd ~/
	  ubuntu@ip-172-31-27-243:~$ argo list -n onap | grep ts
	  ts9dt4xz             Succeeded   2h    40s        1

	  ubuntu@ip-172-31-27-243:~$ docker ps -a | grep ts9dt4xz
	  b1bd76609t06        689546000088                                       "/var/run/argo/argoe…"    About an two ago   Exited (0) About an hour ago    k8s_main_ts9dt4xz_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

	  docker cp b1bd76609t06:/tmp/xapp.log /home/ubunut/ts_xapp.log
    
	# To check ts models deploy successfully, verify the following messages in /home/ubunut/ts_xapp.log.
    *         ric       ric       ric        
	Found RIC_HOST = 18.118.55.192
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
									 Dload  Upload   Total   Spent    Left  Speed

	 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
	100   627  100    28  100   599    148   3169 --:--:-- --:--:-- --:--:--  3300
	100   627  100    28  100   599    148   3169 --:--:-- --:--:-- --:--:--  3300
	{
		"status": "Created"
	}
	*         ric       ric       ric        
	Found RIC_HOST = 18.118.55.192
	   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
		    							 Dload  Upload   Total   Spent    Left  Speed

	 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
	100    27    0     0  100    27      0     22  0:00:01  0:00:01 --:--:--    22
	100   103  100    76  100    27     63     22  0:00:01  0:00:01 --:--:--    85
	{"instances":null,"name":"trafficxapp","status":"deployed","version":"1.0"}
    ```    	  		   
