# GIN 
Table of contents
=================
<!--ts-->
   * [Introduction](#Introduction)
   * [Pre Deployment Steps](#Pre-Deployment-Steps)
   * [Building Tosca Model Csars](#Building-Tosca-Model-Csars)
   * [Building images and starting docker containers of puccini tosca components](#Building-images-nd-starting-docker-containers-of-puccini-tosca-components)
   * [Deploying Tosca Models](#Deploying-Tosca-Models)
   * [Summary Of Options Available](#Summary-Of-Options-Available)
   * [Steps To Verify Deloyed Tosca Models](#Steps-To-Verify-Deloyed-Tosca-Models)
<!--te-->  

## Introduction(TBD)

  This page is describe step to follow to create necessary environment for deploying tosca models including pre & post deployment and verification steps.


## Pre Deployment Steps
- **DMaaP Server:**

  - Create AWS VM (DMaaP server) in Ohio region with following specifications and SSH it using putty:
    
    ```sh
    Image: ubuntu-18.04
    Instance Type: t2.large
    Storage: 80GB
    Key Pair: cciPublicKey
    ``` 
  - Setup Docker on DMaaP server:
    ```sh
    sudo apt update
    sudo apt install docker.io
    sudo apt  install docker-compose
	Create daemon.json in /etc/docker and following in it.
       { "insecure-registries":["172.31.27.186:5000"] }
    sudo systemctl stop docker.socket 
    sudo systemctl start docker
    sudo chmod 777 /var/run/docker.sock
    ```
    Make sure docker is installed properly by running following command :		
    ```sh
    docker info
    ```	
  - Clone the messageservice folder:
    ```sh
	cd ~/
    mkdir ~/local-dmaap
	cd local-dmaap
    git clone https://gerrit.onap.org/r/dmaap/messagerouter/messageservice --branch frankfurt
    ```
	
	Note: Verfiy that CCI_REPO VM on Ohio Region is in running state
	
	Replace the docker image in docker-compose.yml as follows:
	
    Go to this location cd /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose/docker-compose.yml	
	
    Image to be replace:
	```sh
	image: nexus3.onap.org:10001/onap/dmaap/dmaap-mr:1.1.18
	```
	New image:
    ```sh          
    image: 172.31.27.186:5000/dmaap:localadapt_0.1
    ```	
	
	Note: 172.31.27.186 is the IP address of CCI_REPO  VM.
	
  - Start DMaaP Server:
    ```sh
    cd /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose
    docker-compose up -d
    ```
  - Verify DMaap Server is deployed:
  
	Run the command given below and verify that the entire containers are UP.
	
	```sh
	ubuntu@message_router:~/local-dmaap/messageservice/target/classes/docker-compose$ docker ps -a
	CONTAINER ID   IMAGE                                              COMMAND                  CREATED         STATUS         PORTS                                                           NAMES
	a234f9f984dd   dmaap:localadapt                                   "sh startup.sh"          6 seconds ago   Up 5 seconds   0.0.0.0:3904-3906->3904-3906/tcp, :::3904-3906->3904-3906/tcp   dockercompose_dmaap_1
	8058f11e9f57   nexus3.onap.org:10001/onap/dmaap/kafka111:1.0.4    "/etc/confluent/dock…"   7 seconds ago   Up 6 seconds   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp, 9093/tcp             dockercompose_kafka_1
	a93fcf78bcb9   nexus3.onap.org:10001/onap/dmaap/zookeeper:6.0.3   "/etc/confluent/dock…"   9 seconds ago   Up 6 seconds   2888/tcp, 0.0.0.0:2181->2181/tcp, :::2181->2181/tcp, 3888/tcp   dockercompose_zookeeper_1
	```
	
	Or run the following command 
	
    ```sh
	curl -X GET "http://{IP_OF_DMaap_Server}:3904/topics"
	{"topics": []}
	```
	
- **Demo server:**

  - Create AWS VM (demo_server) in Ohio region with following specifications and SSH it using putty:
    
    ```sh		
    Image: ubuntu-18.04
    Instance Type: t2.large
    Storage: 80GB
    Key Pair: cciPublicKey
    ```
    
  - Setup Docker on demo_server
    ```sh
    sudo apt update
    sudo apt install docker.io
    sudo apt  install docker-compose
	Create daemon.json in /etc/docker and following in it.
       { "insecure-registries":["172.31.27.186:5000"] }
    sudo systemctl stop docker.socket 
    sudo systemctl start docker
    sudo chmod 777 /var/run/docker.sock
    ```

    Make sure docker is installed properly by running below command:
		
    ```sh
    docker info
    ```
	
- **Oran Servers:**(TBD)

  - Set up the oran Servers on AWS, follow the wiki page:

    ```sh	
    http://54.236.224.235/wiki/index.php/Steps_for_setting_up_clustering_for_ORAN_models
    ```
	
	Note: Setup this oran servers when we want to deploy oran models.
	
- **ONAP_OOM_DEMO:**(TBD)
  
  - Create AWS VM(ONAP_OOM_DEMO) with following specifications and SSH it using Putty:
  
	```sh
	Image: ubuntu-18.04
    Instance Type: m5a.4xlarge
    Storage: 400GB
    KeyPair: cciPublicKey
    ```
  
  - Setup docker:
  
    ```sh
	sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt update
    apt-cache policy docker-ce
    sudo apt-get install containerd.io docker-ce=5:18.09.5~3-0~ubuntu-bionic docker-ce-cli=5:18.09.5~3-0~ubuntu-bionic
    sudo usermod -aG docker ${USER}
    id -nG
    cd //
    sudo chmod -R 777 /etc/docker
    Create daemon.json in /etc/docker and following in it.
     { "insecure-registries":["172.31.27.186:5000"] }
    sudo systemctl stop docker 
    sudo systemctl start docker
    sudo chmod 777 /var/run/docker.sock
	```
	
	Note : 172.31.27.186 is a IP address of 'CCI-REPO' VM
	
  - Setup kubernetes:
  
    ```sh'
	cd home/ubuntu
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.9/bin/linux/amd64/kubectl
    sudo chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    grep -E --color 'vmx|svm' /proc/cpuinfo
	```
	
  - Setup minikube:
    
	```sh
    sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo chmod +x minikube
    sudo mv ./minikube /usr/local/bin/minikube
    sudo apt-get install conntrack
    sudo minikube start --driver=none --kubernetes-version 1.15.9
    sudo mv /home/ubuntu/.kube /home/ubuntu/.minikube $HOME
    sudo chown -R $USER $HOME/.kube $HOME/.minikube
    kubectl get pods -n onap -o=wide
	```
	
  - Download/Clone the CCI ONAP OOM:
    
	```sh
	cd ~/
    git clone https://github.com/customercaresolutions/onap-oom-integ.git -b frankfurt --recurse-submodules
    cd ~/onap-oom-integ/kubernetes
    git clone https://github.com/onap/testsuite-oom -b frankfurt robot
	```
	
  - Install Helm:
  
    ```sh
	cd ~/
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    sudo chmod 700 get_helm.sh
    ./get_helm.sh -v v2.16.6
    sudo cp -R ~/onap-oom-integ/kubernetes/helm/plugins/ ~/.helm
	```
	
  - Run following commands for setting up helm:
  
    ```sh
	sudo helm init --stable-repo-url=https://charts.helm.sh/stable --client-only
    helm --tiller-namespace tiller version
    kubectl -n kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
    sudo helm serve &
    sudo helm repo add local http://127.0.0.1:8879
    sudo helm repo list
    sudo apt install make
    sudo chmod -R 777 .helm
	```
	
  - Run following commands to install python, jq and AWS CLI:
  
	```sh
    sudo apt-get update
    sudo apt install python
    sudo apt-get -y install python-dev python-pip
    sudo pip install --upgrade pip
    sudo apt-get install jq
    sudo apt install awscli
	```
	
  - To deploy oran models create bonap server with clustering enable (ric and nonrtric clusters) using following link:
  
    ```sh
	http://54.236.224.235/wiki/index.php/Steps_for_setting_up_clustering_for_ORAN_models
	```
  
  - Add Public IP of bonap Server VM in ~/onap-oom-integ/cci/application.cfg file:

    ```sh
    [remote]
    remoteHost={bonap_server}
    remotePort=22
    remoteUser=ubuntu
    remotePubKey=/opt/app/config/cciPrivateKey
	```	
	
	Note1: IP_of_server if we want to deploy sdwan, firewall then use IP_of_demo_server(which we created in Pre Deployment). 
	         
			if we want to deploy firewall, sdwan & oran models then use IP_of_bonap_server(which we created in Pre Deployment).

			IP_OF_DMaap_Server is a server which we created in Pre Deployment.
			 
	Note2: cciPrivateKey is the Key to login/ssh into AWS.
	
  - Build helm charts:
  
    ```sh
	cd /home/ubuntu/onap-oom-integ/kubernetes
    make SKIP_LINT=TRUE all; make SKIP_LINT=TRUE onap
    helm search onap -l
    sudo cp -R ~/onap-oom-integ/kubernetes/helm/plugins/ ~/.helm
    cd ../..
    sudo chmod -R 777 .helm
    sudo apt-get install socat
	```
	
	Note: Verify 'CCI-REPO' VM on AWS Ohio Region should be in running state.
	
  - Deploy ONAP:
    
	```sh
	cd ~/onap-oom-integ/kubernetes
    helm deploy onap local/onap --namespace onap --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 900
	kubectl get pods -n onap
	```
	
	Note: Wait till all pods go into 'Running' state.
	
  -	To access portal using browser from your local machine, add 'ip_of_ONAP_OOM_DEMO' in /etc/hosts file:
  
	```sh
	{ip_of_ONAP_OOM_DEMO} portal.api.simpledemo.onap.org    
    {ip_of_ONAP_OOM_DEMO} vid.api.simpledemo.onap.org
    {ip_of_ONAP_OOM_DEMO} sdc.api.simpledemo.onap.org
    {ip_of_ONAP_OOM_DEMO} sdc.api.fe.simpledemo.onap.org
    {ip_of_ONAP_OOM_DEMO} cli.api.simpledemo.onap.org
    {ip_of_ONAP_OOM_DEMO} aai.api.sparky.simpledemo.onap.org
    {ip_of_ONAP_OOM_DEMO} sdnc.api.simpledemo.onap.org
	```
	
  -	Access ONAP portal from browser:
    
	```sh
	https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm
	```
	
  Note: Setup this server when we want to test through ONAP OOM environment.
	
## Building Tosca Model Csars

- **List Of Models And Their Summary:**
	
	To Build the csar of each model we have to first clone the tosca-models on Demo Server from github for that use the below link and store it on /home/ubuntu.
	```sh
	git clone https://github.com/customercaresolutions/tosca-models 
	```
	Run following commands to build model csar.
	
  - SDWAN:
    Go to the cd /home/ubuntu/tosca-models/cci/sdwan and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```  
  - FW:
    Go to the cd /home/ubuntu/tosca-models/cci/firewall and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - NONRTRIC:
    Go to the cd /home/ubuntu/tosca-models/cci/nonrtric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - RIC:
    Go to the cd /home/ubuntu/tosca-models/cci/ric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP:
    Go to the cd /home/ubuntu/tosca-models/cci/qp and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP-DRIVER:
    Go to the cd /home/ubuntu/tosca-models/cci/qp-driver and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - TS:
    Go to the cd /home/ubuntu/tosca-models/cci/ts and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
    
    Check wither all csar are created at home/ubuntu/tosca-models/cci.
    
## Building images and starting docker containers of puccini tosca components
- **List of components and their summary:**(TBD)
   
    GIN consists of following components which need to be build puccini repository
    
  - TOSCA_SO
  - TOSCA_COMPILER
  - TOSCA_WORKFLOW
  - TOSCA_POLICY
  - TOSCA_GAWP

- **Steps for Building Images and starting docker containers:**

	Login into the demo_server and perform the steps as follows:
	
  - clone puccini:
    ```sh
	cd ~/
    git clone https://github.com/customercaresolutions/puccini
    ```
  - Make following changes in puccini as follows:

	- puccini/docker-compose.yml:
		
		  orchestrator:
			  build:
			    context: .
			    dockerfile: Dockerfile.so.multistage
			  volumes:
			    -  ./dvol/config:/opt/app/config
			    -  ./dvol/models:/opt/app/models
			    -  ./dvol/data:/opt/app/data
			    -  ./dvol/log:/opt/app/log		   
		  compiler:
			  build:
			    context: .
			    dockerfile: Dockerfile.compiler.multistage
			  volumes:
			    -  ./dvol/config:/opt/app/config
			    -  ./dvol/models:/opt/app/models
			    -  ./dvol/data:/opt/app/data
			    -  ./dvol/log:/opt/app/log
		  workflow:
			  build:
			    context: .
			    dockerfile: Dockerfile.workflow.multistage
			  volumes:
			    -  ./dvol/config:/opt/app/config
			    -  ./dvol/models:/opt/app/models
			    -  ./dvol/data:/opt/app/data
			    -  ./dvol/log:/opt/app/log
		  policy:
			  build:
			    context: .
			    dockerfile: Dockerfile.policy.multistage
			  volumes:
			    -  ./dvol/config:/opt/app/config
			    -  ./dvol/models:/opt/app/models
			    -  ./dvol/data:/opt/app/data
			    -  ./dvol/log:/opt/app/log
		  gawp:
			  build:
			    context: .
			    dockerfile: Dockerfile.gawp.multistage
			  volumes:
			     -  ./dvol/config:/opt/app/config
			     -  ./dvol/models:/opt/app/models
			     -  ./dvol/data:/opt/app/data
			     -  ./dvol/log:/opt/app/log 

	- Modify ~/puccini/dvol/config/application.cfg as follows:					
			
		  [remote]
		  remoteHost={IP_of_server}
		  remotePort=22
		  remoteUser=ubuntu
		  remotePubKey=/opt/app/config/cciPrivateKey
		  msgBusURL={IP_OF_DMaap_Server}:3904
		  schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt
				  
	  Note1: IP_of_server if we want to deploy sdwan, firewall then use IP_of_demo_server(which we created in Pre Deployment). 
	         
			if we want to deploy firewall, sdwan & oran models then use IP_of_bonap_server(which we created in Pre Deployment).

			IP_OF_DMaap_Server is a server which we created in Pre Deployment.
			 
	  Note2: cciPrivateKey is the Key to login/ssh into AWS.   
	  
	- Copy files as given follows:
	  
	  ```sh
	  cd puccini/dvol/
	  mkdir models
	  cd ~/
	  cp sdwan.csar firewall.csar qp.csar qp-driver.csar ts.csar nonrtric.csar ric.csar puccini/dvol/models
	  cp cciPrivateKey puccini/dvol/config
	  ```
	  - Copy /puccini/config/TOSCA-Dgraph-schema.txt to /puccini/dvol/config/

  - Build Docker images:
    ```sh
    cd ~/puccini
    docker-compose up -d
    ```

  - Check either the images are created:
    ```sh
    docker images -a
    ```
	
  - Verify docker containers  are deployed:

    All containers should be up.
   
    ```sh
    e.g:
    ubuntu@ip-172-31-19-128:~/puccini$ docker ps -a
	CONTAINER ID   IMAGE                       COMMAND              CREATED          STATUS          PORTS                                                                                                                             NAMES
	a376e8a6e376   cci/tosca-so:latest         "./tosca-so"         16 minutes ago   Up 16 minutes   0.0.0.0:10000->10000/tcp, :::10000->10000/tcp                                                                                     puccini_orchestrator_1
	03b84c611ff1   cci/tosca-workflow:latest   "./tosca-workflow"   16 minutes ago   Up 16 minutes   0.0.0.0:10020->10020/tcp, :::10020->10020/tcp                                                                                     puccini_workflow_1
	f6d21d918951   cci/tosca-compiler:latest   "./tosca-compiler"   16 minutes ago   Up 16 minutes   0.0.0.0:10010->10010/tcp, :::10010->10010/tcp                                                                                     puccini_compiler_1
	c1bea75442a6   cci/tosca-gawp:latest       "./tosca-gawp"       16 minutes ago   Up 16 minutes   0.0.0.0:10040->10040/tcp, :::10040->10040/tcp                                                                                     puccini_gawp_1
	0b540079edfb   cci/tosca-policy:latest     "./tosca-policy"     16 minutes ago   Up 16 minutes   0.0.0.0:10030->10030/tcp, :::10030->10030/tcp                                                                                     puccini_policy_1
	0557555424a6   dgraph/standalone:latest    "/run.sh"            16 minutes ago   Up 16 minutes   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp, 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:9080->9080/tcp, :::9080->9080/tcp   puccini_dgraphdb_1

    ```
## Summary Of Options Available

  Following are the short description of various options in request body while creating service instance.(TBD)

- list-steps-only:
 
  There is option called "list-steps-only" key-pair present in API body If the "list-steps-only" value is "true" means we are just list the steps of deployment and if value of it   is "false" it means we deploy model on AWS.
  
- execute-workflow:


## Deploying Tosca Models

   There are two ways to deploy tosca models one is Docker Containers and the other is using ONAP OOM environment. 
    
  - **Docker Containers:** 
   
    There are several CCI models in puccini tosca as follows:
	
	**#Sdwan** 
	
	**#Firewall**
	
	**#Oran (Nonrtric, Ric, Qp, Qp-driver, Ts)** 

	- Store model in Dgraph:
	  
	  ```sh
	  POST http://{IP_of_demo_server}:10010/compiler/model/db/save
	  {
		  "url":"/opt/app/models/<ModelName>.csar",
		  "output": "./<ModelName>-dgraph-clout.json",
		  "resolve":true,
		  "quirks": ["data_types.string.permissive"],
		  "inputs":"",
		  "inputsUrl": ""
	  }
	  ```  		 
	  For sdwan,firewall,nonrtric,qp,qp-driver,ts use following:
	  ```sh
		{
		  "inputs":"",
		  "url":"/opt/app/models/<model_name>.csar",
		  "output": "./<model_name>-dgraph-clout.json",
		}
	  ```
      For ric use following:
	  ```sh
,		  "inputs":{"helm_version":"2.17.0"},
		  "url":"/opt/app/models/ric.csar",
		  "output": "./ric-dgraph-clout.json",
		}
      ```	  
	  
	- Create Service Instances Without Deployment:
	
	  Note: To  Deploy models while create instance ("list-steps-only":true and "execute-policy":false)
	
	  For Sdwan, Firewall, Nonrtric, Ric, qp, qp-driver, ts:
	  ```sh			
	  POST http://{IP_of_demo_server}:10000/bonap/templates/createInstance
	  {
		"name" : "<Instance_Name>",
		"output": "../../workdir/<ModelName>-dgraph-clout.yaml",
		"inputs": "<input_for_model>",
		"inputsUrl":"<input_url_for_model>",
		"generate-workflow":true,
		"execute-workflow":true,
		"list-steps-only":true,
		"service":"<service_url_for_model>"
	  }
	  ```
	  
      Use Following InputUrl and Service in API body for:
	  
	  **Firewall:**  
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml",
	    "execute-policy":false
	  ```
	  
	  **Sdwan:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml",
	    "execute-policy":false
	  ```
	  
	  **Ric:**
	  ```sh
	    "inputs":{"helm_version":"2.17.0"},
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/ric.csar!/ric.yaml",
	    "execute-policy":false
	  ```	
	  
	  **Nonrtric:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/nonrtric.csar!/nonrtric.yaml",
        "execute-policy":false
	  ```
	  
	  **Qp:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/qp.csar!/qp.yaml",
	    "execute-policy":false
	  ```
	 
	  **Qp-driver:**
	  ```sh
	     "inputs":"",
	     "inputsUrl":"",
	     "service":"zip:/opt/app/models/qp-driver.csar!/qp-driver.yaml",
             "execute-policy":false
	  ```
	 
	  **Ts:**
	  ```sh
	     "inputs":"",
	     "inputsUrl":"",
	     "service":"zip:/opt/app/models/ts.csar!/ts.yaml",
	     "execute-policy":false
	   ```

	- Create Service Instances With Deployment:
	  
	  Note: To Deploy models while create instance ("list-steps-only":false and "execute-policy":true)
	
	  For Sdwan, Firewall, Nonrtric, Ric, qp, qp-driver, ts:
	  ```sh			
	  POST http://{IP_of_demo_server}:10000/bonap/templates/createInstance
	  {
		"name" : "<Instance_Name>",
		"output": "../../workdir/<ModelName>-dgraph-clout.yaml",
		"inputs": "<input_for_model>",
		"inputsUrl":"<input_url_for_model>",
		"generate-workflow":true,
		"execute-workflow":true,
		"list-steps-only":false,
		"service":"<service_url_for_model>"
	  }
	  ```	
	  
      Use Following InputUrl and Service in API body for:

	  **Firewall:**  
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml",
	    "execute-policy":true
	  ```
	  
	  **Sdwan:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml",
	    "execute-policy":true
	  ```
	  
	  **Ric:**
	  ```sh
	    "inputs":{"helm_version":"2.17.0"},
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/ric.csar!/ric.yaml",
	    "execute-policy":true
	  ```	
	  
	  **Nonrtric:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/nonrtric.csar!/nonrtric.yaml",
        "execute-policy":true
	  ```
	  
	  **Qp:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/qp.csar!/qp.yaml",
	    "execute-policy":true
	  ```
	 
	  **Qp-driver:**
	  ```sh
	     "inputs":"",
	     "inputsUrl":"",
	     "service":"zip:/opt/app/models/qp-driver.csar!/qp-driver.yaml",
         "execute-policy":true
	  ```
	 
	  **Ts:**
	  ```sh
	     "inputs":"",
	     "inputsUrl":"",
	     "service":"zip:/opt/app/models/ts.csar!/ts.yaml",
	     "execute-policy":true
	  ```

	- ExecuteWorkfow Service without Deployment:
	  
	  Note: ExecuteWorkfow API Without Deploy("list-steps-only":true)
	  
	  ```sh
          POST http://{IP_of_demo_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
	  {
	      "list-steps-only": true,
	      "execute-policy": false
	  }
	  ```		 

	- ExecuteWorkfow Service with Deployment:
	  
	  Note: ExecuteWorkfow API With Deploy("list-steps-only":false)
	   
	  ```sh	
          POST http://{IP_of_demo_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
	  {
              "list-steps-only": false,
	      "execute-policy": true
	  }
	  ```
	  
	  Note: Following API's are only applicable for the firewall model.
	  
	- Execute Policy: 
	  
	  ```sh
	  POST http://{IP_of_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
	  ```
	  
        - Stop Policy:
         
	  ```sh
	  DELETE http://{IP_of_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
   	  ```
	  
        - Get Policies:
         
	  ```sh
	  GET http://{IP_of_demo_server}:10000/bonap/templates/<InstanceName>/policies
	  ```
	  
  - **ONAP OOM:**(TBD)
  
    As we see the all CCI model in docker container method same deployemnt we are going to do with OOM based ONAP environment.
	for that we have to follow the below step.
	
    - One time Steps for intialization/configuration the envinorment:
	  
	  Login ONAP portal using designer(cs0008/demo123456!) and follow the steps as follows: 
	  
	  ```sh
	  https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm
	  Virtual Licence Model creation
      Open SDC application, click on the 'ONBOARD' tab.
      Click 'CREATE NEW VLM' (Licence Model)
      Use 'cci' as Vendor Name, and enter a description
      Click 'CREATE'
      Click 'Licence Key Groups' and 'ADD LICENCE KEY GROUP', then fill in the required fields
      Click 'Entitlements Pools' and 'ADD ENTITLEMENTS POOL', then fill in the required fields
      Click 'Feature Groups' and 'ADD FEATURE GROUP', then fill in the required fields. Also, under the Entitlement 
      Pools tab, drag the created entitlement pool to the left. Same for the License Key Groups
      Click Licence Agreements and 'ADD LICENCE AGREEMENT', then fill in the required fields. Under the tab 
      Features Groups, drag the feature group created previously.
      Click on 'SUBMIT' and add comment then click on 'COMMIT & SUBMIT' .
	  ```
	   
	- Create and Distribute CCI models in SDC:
	
	- Create service instance and VNF from VID:
	
    
  
## Steps to Verify Deloyed Tosca Models 
 
  Below steps help us to verfiy Firewall,Sdwan,Oran(nonrtric,ric,qp,qp-driver,ts) model is deploy or not.
  
- Verify Sdwan Model:  
 
  - Verify {service_instance_name}_SDWAN_Site_A and {service_instance_name}_SDWAN_Site_B VMs should be created on AWS.
  - SSH SDWAN_Site_A VM and fire 'ifconfig -a'
	Ping WAN Public IP, LAN Private IP(vvp1) and VxLAN IP(vpp2) of SDWAN_Site_B.
  - SSH SDWAN_Site_B VM and fire 'ifconfig -a'
	Ping WAN Public IP, LAN Private IP(vvp1) and VxLAN IP(vvp2) of SDWAN_Site_A.
  - Compare tosca-models/cci/sdwanCsarClout.json with puccini/so/sdwan-dgraph-clout.json using compare tool.
	
- Verify Firewall Model:

  - Browse the metrics using browser at http://{IP_OF_PACKET_SINK}:667
	  Validate that number of captured packets by sink will gets increase in 'Graphs' section
  - Compare tosca-models/cci/firewallCsarClout.json with puccini/so/firewall-dgraph-clout.json using compare tool.

- Verify Nonrtric Model:
	
  - Comaands to verify all pods are running using following commands on bonap-server: 
    ```sh
	kubectl get pods -n nonrtric
	```     
  - Compare tosca-models/cci/nonrtricCsarClout.json with puccini/so/nonrtric-dgraph-clout.json using compare tool.
	
- Verify Ric Model:

  - Comaands to verify all pods are running using following commands :
	```sh		
	kubectl get pods -n ricplt
	kubectl get pods -n ricinfra
	kubectl get pods -n ricxapp   	   
	```		
  - Compare tosca-models/cci/ricCsarClout.json with puccini/so/ric-dgraph-clout.json using compare tool.

- Verify Qp Model:

  - Login 'bonap-server' and go to /tmp folder and see logs to check whether deployment is successful or not
          To check qp models deploy successfully, verify following messages in /tmp/xapp.log. 
	  {"instances":null,"name":"qp","status":"deployed","version":"1.0"}	  
  - Compare tosca-models/cci/qpCsarClout.json with puccini/so/qp-dgraph-clout.json using compare tool.

- Verify Qp-driver Model:

  - Login 'bonap-server' and go to /tmp folder and see logs to check whether deployment is successful or not
          To check qp-driver models deploy successfully, verify following messages in /tmp/xapp.log. 
          {"instances":null,"name":"qp-driver","status":"deployed","version":"1.0"} 
  - Compare tosca-models/cci/qpDriverCsarClout.json with puccini/so/qp-driver-dgraph-clout.json using compare tool.

- Verify Ts Model:

  - Login 'bonap-server' and go to /tmp folder and see logs to check whether deployment is successful or not
          To check ts models deploy successfully, verify following messages in /tmp/xapp.log. 
          {"instances":”null,"name":"trafficxapp","status":"deployed","version":"1.0"}	  		   
  - Compare tosca-models/cci/tsCsarClout.json with puccini/so/ts-dgraph-clout.json using compare tool.
