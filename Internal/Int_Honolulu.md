# Int_Honolulu

## Table of contents

<!--ts-->
   * [Introduction](#Introduction)
   * [Creating an environment for OOM VM of HONOLULU release](#Creating-an-environment-for-OOM-VM-of-HONOLULU-release)
   * [Testing of tosca models in HONOLULU release](#Testing-of-tosca-models-in-HONOLULU-release)
   * [ONAP OOM testing](#ONAP-OOM-testing)
   * [Post Deployment Verification Steps](#Post-Deployment-Verification-Steps)
<!--te-->

## Introduction
  
  This page describes steps that need to be followed to create the necessary environment for deploying tosca models using built-in workflow or argo-workflow.
	
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
		
		https://github.com/rajeshvkothari3003/oom/blob/master/GIN_README_2508.md#ORAN-Servers
	  
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
		  
		  **IMP Note: Above YAML must be in a valid format. check whether proper indentation is used.**

		  To know more about valid YAML format use the follwoing link: 

		  ```sh
		  https://jsonformatter.org/yaml-validator
		  ```
		  
    - Make the changes as per the requirement in the ~/onap-oom-integ/cci/application.cfg: 
	  
	  - For built-in(puccini) workflow:
	    
		```sh
		[remote]
		remoteHost={IP_ADDR_OF_SERVER}
		reposureHost={IP_ADDR_OF_ONAP_OOM_DEMO}
		remotePort=22
		remoteUser=ubuntu
		remotePubKey=/opt/app/config/cciPrivateKey
		workflowType=puccini-workflow
		```
		
		Note: {IP_ADDR_OF_SERVER} should be set to {IP_ADDR_OF_ONAP_OOM_DEMO} for deploying sdwan, firewall. In the case of oran models, it should be set to {IP_ADDR_OF_BONAP_SERVER}.
				
      - For argo-workflow:

		```sh
		remoteHost={IP_ADDR_OF_ONAP_OOM_DEMO}
		reposureHost={IP_ADDR_OF_ONAP_OOM_DEMO}
		ricServerIP={IP_ADDR_OF_RIC}
		nonrtricServerIP={IP_ADDR_OF_NONRTRIC}
		workflowType=argo-workflow
		argoTemplateType=containerSet | DAG
        ```		
		
		Note: To deploy a firewall and sdwan models only add {IP_ADDR_OF_ONAP_OOM_DEMO} and for oran models add all IPs.
		
		In argo workflow, there are two ways for executing argo templates.
		
        - containerSet: A containerSet template is similar to a normal container or script template but allows you to specify multiple containers to run within a single pod.
				
	      For using containerSet based argo template use as follows:
	    
		  ```sh
		  argoTemplateType=containerSet
		  ```
			
        - DAG: DAG (Directed Acyclic Graph) contains a set of steps (nodes) and the dependencies (edges) between them.
				
	      For using DAG-based argo template use as follows:
		
		  ```sh	
		  argoTemplateType=DAG
		  ```
		
    - Install golang:
	  
	  ```sh
	  $ cd /home/ubuntu
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
	  
	  # For DAG use the following command:
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
	  
	  This step requires around 35-40 min to deploy ONAP.
	  
	- To deploy only sdwan and firewall model with built-in(puccini) workflow do some additional installation on ONAP_OOM_DEMO  VM as follows:
	  
	  ```sh
	  $ sudo apt-get update
      $ sudo apt-get install -y python
      $ sudo apt-get install -y python3-dev python3-pip
      $ sudo pip3 install --upgrade pip
      $ sudo pip3 install simplejson
      $ sudo apt-get install jq
      $ sudo apt install awscli
      $ sudo apt install python-pip
      $ pip2 install simplejson
	  ```
	  
	- To verify that ONAP is deployed successfully, use the following command and check that all pods are in running state:

      ```sh
	  $ kubectl get pods -n onap
	  
	  ubuntu@ip-172-31-29-51:~/onap-oom-integ/kubernetes$ kubectl get pods -n onap
	  NAME                                           READY   STATUS             RESTARTS   AGE
	  argo-server-fc8b6dfc9-wchnq                    1/1     Running            0          52m
	  onap-aaf-cass-54c568c8cf-8blvq                 1/1     Running            0          41m
	  onap-aaf-cm-8649d449f6-8cwxf                   1/1     Running            0          41m
	  onap-aaf-fs-5864f44d-wd2xj                     1/1     Running            0          41m
	  onap-aaf-gui-7496fcc766-nfhpz                  1/1     Running            0          41m
	  onap-aaf-locate-5c64459758-thr9t               1/1     Running            0          41m
	  onap-aaf-oauth-588658b9dd-vmgms                1/1     Running            0          41m
	  onap-aaf-service-78579cb56f-qnvhz              1/1     Running            0          41m
	  onap-aaf-sms-5b45b944d9-gdphg                  1/1     Running            0          41m
	  onap-aaf-sms-preload-knsmz                     0/1     Completed          0          41m
	  onap-aaf-sms-quorumclient-0                    1/1     Running            0          41m
	  onap-aaf-sms-quorumclient-1                    1/1     Running            0          40m
	  onap-aaf-sms-quorumclient-2                    1/1     Running            0          39m
	  onap-aaf-sms-vault-0                           2/2     Running            0          41m
	  onap-aaf-sshsm-distcenter-wkjgr                0/1     Completed          0          41m
	  onap-aaf-sshsm-testca-c4kzl                    0/1     Completed          0          41m
	  onap-aai-58c68fb8fc-fnh96                      1/1     Running            0          41m
	  onap-aai-babel-d6d9b588-qmw9m                  2/2     Running            0          41m
	  onap-aai-graphadmin-6d8c65bccf-vkdt9           2/2     Running            0          41m
	  onap-aai-graphadmin-create-db-schema-vzz8s     0/1     Completed          0          41m
	  onap-aai-modelloader-857d4697b-4swwm           2/2     Running            0          41m
	  onap-aai-resources-5857bf6bb8-dm2gs            2/2     Running            0          41m
	  onap-aai-schema-service-7c5d56d55-jjsr6        2/2     Running            0          41m
	  onap-aai-sparky-be-55db5b5d74-6fzmj            2/2     Running            0          41m
	  onap-aai-traversal-759cc5c867-kfm8z            2/2     Running            0          41m
	  onap-aai-traversal-update-query-data-hv5lx     0/1     Completed          0          41m
	  onap-awx-0                                     1/4     ImagePullBackOff   0          40m
	  onap-awx-postgres-66886c8994-7vgzc             1/1     Running            0          40m
	  onap-awx-spwsv                                 0/1     Completed          0          40m
	  onap-cassandra-0                               1/1     Running            0          41m
	  onap-cassandra-1                               1/1     Running            0          37m
	  onap-cassandra-2                               1/1     Running            0          33m
	  onap-dbc-pg-primary-78585f6b7-fl58j            1/1     Running            0          39m
	  onap-dbc-pg-replica-58ff5d98dc-p2qqz           1/1     Running            0          39m
	  onap-dmaap-bc-76bb577d58-qgfd9                 1/1     Running            0          39m
	  onap-dmaap-bc-dmaap-provisioning-kwcbt         0/1     Init:Error         0          39m
	  onap-dmaap-bc-dmaap-provisioning-zz6x4         0/1     Completed          0          29m
	  onap-dmaap-dr-db-0                             2/2     Running            0          39m
	  onap-dmaap-dr-node-0                           2/2     Running            0          39m
	  onap-dmaap-dr-prov-6f7465bbc6-xnh9x            2/2     Running            0          39m
	  onap-ejbca-ccb7b44c6-vfb7f                     1/1     Running            0          40m
	  onap-ejbca-config-config-job-66d9b             0/1     Completed          0          30m
	  onap-ejbca-config-config-job-8gwpp             0/1     Init:Error         0          40m
	  onap-mariadb-galera-0                          2/2     Running            0          39m
	  onap-mariadb-galera-1                          2/2     Running            0          34m
	  onap-mariadb-galera-2                          2/2     Running            0          26m
	  onap-message-router-0                          1/1     Running            0          39m
	  onap-message-router-kafka-0                    1/1     Running            0          39m
	  onap-message-router-kafka-1                    1/1     Running            0          39m
	  onap-message-router-kafka-2                    1/1     Running            0          39m
	  onap-message-router-zookeeper-0                1/1     Running            0          39m
	  onap-message-router-zookeeper-1                1/1     Running            0          39m
 	  onap-message-router-zookeeper-2                1/1     Running            0          39m
	  onap-netbox-app-674f9d5f-lvjm8                 1/1     Running            1          40m
	  onap-netbox-app-provisioning-xw45w             0/1     ImagePullBackOff   0          40m
	  onap-netbox-nginx-76464b784-j97wp              1/1     Running            0          40m
	  onap-netbox-postgres-594f478d68-kqp8t          1/1     Running            0          40m
	  onap-portal-app-964f7cf5-x75r2                 2/2     Running            0          39m
	  onap-portal-cassandra-dd4fc76b7-s4gn7          1/1     Running            0          39m
	  onap-portal-db-5d4db9d8dd-trxpc                1/1     Running            0          39m
	  onap-portal-db-config-bsrc5                    0/2     Completed          0          39m
	  onap-portal-sdk-644d7bfdfd-54kql               2/2     Running            0          39m
	  onap-portal-widget-5fcb9c4d89-zb97c            1/1     Running            0          39m
	  onap-robot-7f59bd9f97-tg4gm                    1/1     Running            0          39m
	  onap-sdc-be-558b4d86cf-xl88g                   2/2     Running            0          38m
	  onap-sdc-be-config-backend-kf68n               0/1     Completed          0          38m
	  onap-sdc-cs-config-cassandra-54qtd             0/1     Completed          0          38m
	  onap-sdc-fe-679bc6f44d-gw58q                   2/2     Running            0          38m
	  onap-sdc-onboarding-be-78d5d955b4-8pz2n        2/2     Running            0          38m
	  onap-sdc-onboarding-be-cassandra-init-cts5x    0/1     Completed          0          38m
	  onap-sdc-wfd-be-7956d95666-g9nqz               1/1     Running            0          38m
	  onap-sdc-wfd-be-workflow-init-hzwq5            0/1     Completed          0          38m
	  onap-sdc-wfd-fe-76c94bc665-75d7t               2/2     Running            0          38m
	  onap-so-5d48886cb8-c2mq7                       2/2     Running            0          27m
	  onap-so-admin-cockpit-584d586894-b24nm         1/1     Running            0          27m
	  onap-so-bpmn-infra-7868f977d4-ntbnc            2/2     Running            0          27m
	  onap-so-catalog-db-adapter-5bdd4f7ff-wxpqs     1/1     Running            0          27m
	  onap-so-cnf-adapter-5bfbd6486b-br9dd           1/1     Running            0          27m
	  onap-so-etsi-nfvo-ns-lcm-59f455d7b-m268f       1/1     Running            4          27m
	  onap-so-etsi-sol003-adapter-794d599bbb-9f9cp   1/1     Running            0          27m
	  onap-so-etsi-sol005-adapter-698447dc8b-4d96g   1/1     Running            0          27m
	  onap-so-mariadb-config-job-9wsx9               0/1     Completed          0          27m
	  onap-so-nssmf-adapter-7687766f-rgjsq           1/1     Running            0          27m
	  onap-so-oof-adapter-847bf7f67f-n4xlv           2/2     Running            0          27m
	  onap-so-openstack-adapter-56fb87f5d9-x89gs     2/2     Running            0          27m
	  onap-so-request-db-adapter-666fdf8f7f-xzwcr    1/1     Running            0          27m
	  onap-so-sdc-controller-856b9596c-z9q6v         2/2     Running            0          27m
	  onap-so-sdnc-adapter-fb94764c8-5np85           2/2     Running            0          27m
	  onap-tosca-858768ff5b-k8t9l                    2/2     Running            0          22m
	  onap-tosca-compiler-6c58c67657-pfkxd           2/2     Running            0          22m
	  onap-tosca-dgraph-56cdf6ddd9-65szw             2/2     Running            0          22m
	  onap-tosca-gawp-684d7b8544-lh9n8               2/2     Running            0          22m
	  onap-tosca-policy-7754748966-fhw26             2/2     Running            0          22m
	  onap-tosca-workflow-76445fb68-mpn6n            2/2     Running            0          22m
	  onap-vid-7b5c7f48f9-24x6g                      2/2     Running            0          22m
	  onap-vid-mariadb-init-config-job-rt4d4         0/1     Completed          0          22m
	  workflow-controller-7fb47d49bb-gt88k           1/1     Running            0          52m
	  ```
	
	- Copy latest models csars to ~/onap-oom-integ/cci directory in ONAP_OOM_DEMO VM.

## Testing of tosca models in HONOLULU release

  Currently, testing of tosca models in Honolulu is done using REST API requests sent from POSTMAN. These requests and their order is described as follows.

- Store models in Dgraph:

  For sdwan, firewall, nonrtric, qp, qp-driver, ts models use following:
    
  ```sh
  POST http://{IP_ADDR_OF_ONAP_OOM_DEMO}:30294/compiler/model/db/save
  {
    "url": "/opt/app/config/{MODEL_NAME}.csar",
    "resolve": true,
    "coerce": false,
    "quirks": [
        "data_types.string.permissive"
    ],
    "output": "./{MODEL_NAME}-dgraph-clout.json",
    "inputs": "",
    "inputsUrl": ""
  }
  ```
	  
  For ric model use following:
	  
  ```sh
  {
    "url": "/opt/app/config/ric.csar",
    "resolve": true,
    "coerce": false,
    "quirks": [
        "data_types.string.permissive"
    ],
    "output": "./ric-dgraph-clout.json",
    "inputs": {
        "helm_version": "2.17.0"
    },
    "inputsUrl": ""
  }
  ```
	
- Create service instance:
	
  For sdwan, firewall, nonrtric, ric, qp, qp-driver, ts:
	
  ```sh			
  POST http://{IP_ADDR_OF_ONAP_OOM_DEMO}:30280/bonap/templates/createInstance
  {
	 "name":"{INSTANCE_NAME}",
	 "output":"./{MODEL_NAME}.json",
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
  
  Use following REST API for all the models only replace the {INSTANCE_NAME} which we used in the create instance step:
    
  ```sh
  POST http://{IP_ADDR_OF_ONAP_OOM_DEMO}:30280/bonap/templates/{INSTANCE_NAME}/workflows/deploy
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
  
  Also, check registries.yaml has a valid YAML format. if not then validate that YAML format and run the following command to restart Ks3:
  
  ```sh
  $ sudo systemctl restart k3s
  ```
  
  After K3s restart,??check whether it install properly or not and try to deploy the nonrtric model again.??
  
## ONAP OOM testing
   
  Use the following steps in ONAP OOM Environment.
	
  - One time steps for initialization/configuration of the environment:
	  
	- Login into the ONAP portal using designer (cs0008/demo123456!) and follow the steps: 
	  
	  ```sh
	  https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm
	  ```
	  
	  ```sh
	  Virtual Licence Model creation
	  Open the SDC application, click on the 'ONBOARD' tab.
	  Click 'CREATE NEW VLM' (Licence Model)
	  Use 'cci' as Vendor Name, and enter a description
	  Click 'CREATE'
	  Click 'Licence Key Groups' and 'ADD LICENCE KEY GROUP', then fill in the required fields.
	  Click 'Entitlements Pools' and 'ADD ENTITLEMENTS POOL', then fill in the required fields.
	  Click 'Feature Groups' and 'ADD FEATURE GROUP', then fill in the required fields. Also, under the Entitlement 
	  Pools tab,  drag the created entitlement pool to the left. Same for the License Key Groups.
	  Click Licence Agreements and 'ADD LICENCE AGREEMENT', then fill in the required fields. Under the tab 
	  Features Groups, drag the feature group created previously.
	  Click on 'SUBMIT' and add comment then click on 'COMMIT & SUBMIT'.
	  ```
	  
    - Update AAI with the following REST requests using POSTMAN.
	  
	  Use the following headers in a POSTMAN request
	  
      ```sh
      headers :
      Content-Type:application/json
      X-FromAppId:AAI
      Accept:application/json
      X-TransactionId:get_aai_subscr
      Cache-Control:no-cache
      Postman-Token:9f71f570-043c-ec79-6685-d0d599fb2c6f
      ```
		
      - Create 'NCalifornia' region: 
		
	    ```sh
	    PUT https://aai.api.sparky.simpledemo.onap.org:30233/aai/v19/cloud-infrastructure/cloud-regions/cloud-region/aws/NCalifornia
		{
			"cloud-owner": "aws",
			"cloud-region-id": "NCalifornia",
			"tenants": {
			  "tenant": [
			   {
				 "tenant-id": "1",
				 "tenant-name": "admin"
			   }
			  ]
			}
		 }
	    ```
		  
      - Create customer:   
		  
        ```sh
	    PUT https://aai.api.sparky.simpledemo.onap.org:30233/aai/v19/business/customers/customer/CCIDemonstration	
		{
		   "global-customer-id": "CCIDemonstration",
		   "subscriber-name": "CCIDemonstration",
		   "subscriber-type": "INFRA",
		   "service-subscriptions": {
			 "service-subscription": [
			  {
				"service-type": "vSDWAN",
				"relationship-list": {
				   "relationship": [{
						"related-to": "tenant",
						"relationship-data": [
						   {"relationship-key": "cloud-region.cloud-owner", "relationship-value": "aws"},
						   {"relationship-key": "cloud-region.cloud-region-id", "relationship-value": "NCalifornia"},
						   {"relationship-key": "tenant.tenant-id", "relationship-value": "1"}
						 ]
					}]
				 }
			  },
			  {
				"service-type": "vFirewall",
				"relationship-list": {
				   "relationship": [{
						"related-to": "tenant",
						"relationship-data": [
						   {"relationship-key": "cloud-region.cloud-owner", "relationship-value": "aws"},
						   {"relationship-key": "cloud-region.cloud-region-id", "relationship-value": "NCalifornia"},
						   {"relationship-key": "tenant.tenant-id", "relationship-value": "1"}
						 ]
					}]
				 }
			   },
			  {
				"service-type": "vNonrtric",
				"relationship-list": {
				   "relationship": [{
						"related-to": "tenant",
						"relationship-data": [
						   {"relationship-key": "cloud-region.cloud-owner", "relationship-value": "aws"},
						   {"relationship-key": "cloud-region.cloud-region-id", "relationship-value": "NCalifornia"},
						   {"relationship-key": "tenant.tenant-id", "relationship-value": "1"}
						 ]
					}]
				 }
			 },
			{
				"service-type": "vRIC",
				"relationship-list": {
				   "relationship": [{
						"related-to": "tenant",
						"relationship-data": [
						   {"relationship-key": "cloud-region.cloud-owner", "relationship-value": "aws"},
						   {"relationship-key": "cloud-region.cloud-region-id", "relationship-value": "NCalifornia"},
						   {"relationship-key": "tenant.tenant-id", "relationship-value": "1"}
						 ]
					}]
				 }
			 },
			 {
			   "service-type": "vQp",
			   "relationship-list": {
				  "relationship": [{
					   "related-to": "tenant",
					   "relationship-data": [
						  {"relationship-key": "cloud-region.cloud-owner", "relationship-value": "aws"},
						  {"relationship-key": "cloud-region.cloud-region-id", "relationship-value": "NCalifornia"},
						  {"relationship-key": "tenant.tenant-id", "relationship-value": "1"}
						]
				   }]
				}
			},
			 {
			   "service-type": "vQp-driver",
			   "relationship-list": {
				  "relationship": [{
					   "related-to": "tenant",
					   "relationship-data": [
						  {"relationship-key": "cloud-region.cloud-owner", "relationship-value": "aws"},
						  {"relationship-key": "cloud-region.cloud-region-id", "relationship-value": "NCalifornia"},
						  {"relationship-key": "tenant.tenant-id", "relationship-value": "1"}
						]
				   }]
				}
			},
			 {
			   "service-type": "vTs",
			   "relationship-list": {
				  "relationship": [{
					   "related-to": "tenant",
					   "relationship-data": [
						  {"relationship-key": "cloud-region.cloud-owner", "relationship-value": "aws"},
						  {"relationship-key": "cloud-region.cloud-region-id", "relationship-value": "NCalifornia"},
						  {"relationship-key": "tenant.tenant-id", "relationship-value": "1"}
						]
				   }]
				}
			}				
		   ]}
		  }
        ```
		
        For new CCI models add a new service type in the service-subscription list of create customer REST API.
		
      - Create a dummy service:
		
	    ```sh
	    PUT https://aai.api.sparky.simpledemo.onap.org:30233/aai/v19/service-design-and-creation/services/service/e8cb8968-5411-478b-906a-f28747de72cd
	    {
	       "service-id": "e8cb8968-5411-478b-906a-f28747de72cd",
	       "service-description": "CCI"
	    }
	    ```
		  
      - Create zone:
		  
	    ```sh
	    PUT https://aai.api.sparky.simpledemo.onap.org:30233/aai/v19/network/zones/zone/4334ws43
	    {
	       "zone-name": "cci",
	       "design-type":"abcd",
	       "zone-context":"abcd"
	    }
	    ```
		
    - Update VID with the following REST API requests using POSTMAN
	  
      Use the following headers in the POSTMAN request
	  
      ```sh
	  Content-Type:application/json
      X-FromAppId:VID
      Accept:application/json
      X-TransactionId:get_vid_subscr
      Cache-Control:no-cache
      Postman-Token:9f71f570-043c-ec79-6685-d0d599fb2c6f
      ```
		
      - Declare owning entity:
		
	    ```sh
        POST https://vid.api.simpledemo.onap.org:30200/vid/maintenance/category_parameter/owningEntity
        {
		  "options": ["cciowningentity1"]
        }
	    ```
		
      - Create platform:
		
	    ```sh
	    POST https://vid.api.simpledemo.onap.org:30200/vid/maintenance/category_parameter/platform
	    {
		  "options": ["Test_Platform"]
	    }
	    ```
		
      - Create a line of business:
		
        ```sh
 	    POST https://vid.api.simpledemo.onap.org:30200/vid/maintenance/category_parameter/lineOfBusiness
	    { 
	      "options": ["Test_LOB"]
 	    }
	    ```
		
      - Create a project:
		
        ```sh
	    POST https://vid.api.simpledemo.onap.org:30200/vid/maintenance/category_parameter/project
 	    {
		  "options": ["Test_project"]
	    }
        ```
		
  - Create and distribute CCI models in SDC:
	  
    - Vendor Software Product(VSP) onboarding/creation:
	    
	  Login into the portal using designer (cs0008/demo123456!)
	  
	  ```sh
	  https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm
	  Open the SDC application, click on the OnBoard tab.
      Click 'CREATE NEW VSP'
      Give the name to VSP, i.e.  cci_ric_vsp. 
      Select the Vendor as 'cci', Category as 'Network Service (Generic)', ONBOARDING PROCEDURE as 'Network Package' and give it a description then click on 'CREATE'.
      In the 'Software Product Details' box click on the License Agreement as 'Internal' and select 'Licensing Version',
      'License Agreement' and 'Feature Groups'.
      Goto 'Overview'. In??the 'Software Product Attachments' box click on 'SELECT File' and upload nonrtric/ric/qp/qp-driver/ts based on your requirement.
      Click on Submit and enter commit comment then click on 'COMMIT & SUBMIT'.
	  ```
	  
    - Virtual Function (VF) creation:
	  
	  ```sh
	  Go to SDC home. Click on the top-right icon with the orange arrow.
	  Select your VSP and click on 'IMPORT VSP'.
	  Click on 'Create' 
	  Click on 'Check-in' and enter a comment then Press OK.
	  Click on 'Certify' and enter a comment then Press OK.
	  ```
	  
	- Service creation/distribution:
	    
	  ```sh
	  Go to SDC home. From the 'Add' box click on 'ADD SERVICE'
	  Enter Name and then select 'Category' as 'Network Service'. Enter the description and click on Create.
	  Click on the 'Composition' left tab
	  In the search bar, Search your VSP and Drag it
	  Click on 'Check-in' and enter a comment then Press OK.
	  Click on Certify and enter a comment then Press OK.
	  Click on Distribute.
	  Wait for two minutes and go to the 'Distribution' tab of service. You should see 'DISTRIBUTION_COMPLETE_OK'
	  ```
	  
  - Create service instance and VNF from VID:
	
    - Access to VID portal
	    
      Login into the portal using demo/demo123456! credentials.
	  
      ```sh
	  https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm
      ```
		
	  Select the VID icon from portal
		
    - Instantiate service
	    
      ```sh
	  Click 'Browse SDC Service Models'
      Check that all distributed model are there.
      ```

## Post Deployment Verification Steps 
 
  Use the following steps to verify models are deployed successfully. 
  
- Verify sdwan model:  
 
  - Verify {SERVICE_INSTANCE_NAME}_SDWAN_Site_A and {SERVICE_INSTANCE_NAME}_SDWAN_Site_B VMs are created on AWS N.California region.
  - SSH SDWAN_Site_A VM and run the following command:
    
	```sh
	$ ifconfig -a
	
	ubuntu@ip-172-19-254-33:~$ ifconfig -a
	ens5: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9001
			inet 172.19.254.33  netmask 255.255.255.0  broadcast 0.0.0.0
			inet6 fe80::4cf:94ff:fe39:30a7  prefixlen 64  scopeid 0x20<link>
			ether 06:cf:94:39:30:a7  txqueuelen 1000  (Ethernet)
			RX packets 139  bytes 25029 (25.0 KB)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 161  bytes 24640 (24.6 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

	lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
			inet 127.0.0.1  netmask 255.0.0.0
			inet6 ::1  prefixlen 128  scopeid 0x10<host>
			loop  txqueuelen 1000  (Local Loopback)
			RX packets 254  bytes 21608 (21.6 KB)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 254  bytes 21608 (21.6 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

	vpp1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
			inet 172.19.1.249  netmask 255.255.255.0  broadcast 0.0.0.0
			inet6 fe80::476:2dff:fe3c:f8a9  prefixlen 64  scopeid 0x20<link>
			ether 06:76:2d:3c:f8:a9  txqueuelen 1000  (Ethernet)
			RX packets 3  bytes 126 (126.0 B)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 40  bytes 2852 (2.8 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

	vpp2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1350
			inet 10.100.0.18  netmask 255.255.255.254  broadcast 0.0.0.0
			inet6 fe80::27ff:fefd:18  prefixlen 64  scopeid 0x20<link>
			ether 02:00:27:fd:00:18  txqueuelen 1000  (Ethernet)
			RX packets 38  bytes 3260 (3.2 KB)
			RX errors 0  dropped 1  overruns 0  frame 0
			TX packets 50  bytes 4164 (4.1 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
	```
	
    Ping WAN Public IP, LAN Private IP(vpp1), and VxLAN IP(vpp2) of SDWAN_Site_B.
	
  - SSH SDWAN_Site_B VM and run the following command:
    
	```sh
	$ ifconfig -a
	
	ubuntu@ip-172-14-254-13:~$ ifconfig -a
	ens5: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9001
			inet 172.14.254.13  netmask 255.255.255.0  broadcast 0.0.0.0
			inet6 fe80::43f:10ff:fedf:b2b3  prefixlen 64  scopeid 0x20<link>
			ether 06:3f:10:df:b2:b3  txqueuelen 1000  (Ethernet)
			RX packets 322  bytes 38221 (38.2 KB)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 325  bytes 37083 (37.0 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

	lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
			inet 127.0.0.1  netmask 255.0.0.0
			inet6 ::1  prefixlen 128  scopeid 0x10<host>
			loop  txqueuelen 1000  (Local Loopback)
			RX packets 255  bytes 21720 (21.7 KB)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 255  bytes 21720 (21.7 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

	vpp1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
			inet 172.14.1.152  netmask 255.255.255.0  broadcast 0.0.0.0
			inet6 fe80::4a3:43ff:fe0a:33eb  prefixlen 64  scopeid 0x20<link>
			ether 06:a3:43:0a:33:eb  txqueuelen 1000  (Ethernet)
			RX packets 6  bytes 252 (252.0 B)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 63  bytes 4530 (4.5 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

	vpp2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1350
			inet 10.100.0.19  netmask 255.255.255.254  broadcast 0.0.0.0
			inet6 fe80::27ff:fefd:19  prefixlen 64  scopeid 0x20<link>
			ether 02:00:27:fd:00:19  txqueuelen 1000  (Ethernet)
			RX packets 64  bytes 5380 (5.3 KB)
			RX errors 0  dropped 1  overruns 0  frame 0
			TX packets 83  bytes 6698 (6.6 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
	```
	
	Ping WAN Public IP, LAN Private IP(vpp1), and VxLAN IP(vpp2) of SDWAN_Site_A.
	
- Verify firewall model:

  - Verify {SERVICE_INSTANCE_NAME}_firewall, {SERVICE_INSTANCE_NAME}_packet_genrator and {SERVICE_INSTANCE_NAME}_packet_sink VMs are created on AWS N.Virginia region.

- Verify nonrtric model:
	
  - Verify that all pods are in running state using the following command on a nonrtric server: 
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

  - Verify that all pods are in running state using the following command on a ric server:
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

  - Login 'ONAP_OOM_DEMO' and run following commands:
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
	  f1bc78609f02        449444000066                                       "/var/run/argo/argoe???"    About an hour ago   Exited (0) About an hour ago    k8s_main_qp1pq8kc_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

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

  - Login 'ONAP_OOM_DEMO' and run following commands:
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
	  u1ft76609r05        689546000088                                       "/var/run/argo/argoe???"    About an hour ago   Exited (0) About an hour ago    k8s_main_qp-deriver4rq2ws_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

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

  - Login 'ONAP_OOM_DEMO' and run following commands:
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
	  b1bd76609t06        689546000088                                       "/var/run/argo/argoe???"    About an two ago   Exited (0) About an hour ago    k8s_main_ts9dt4xz_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

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
