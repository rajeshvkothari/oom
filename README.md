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
   * [Steps To Verify Deployed Tosca Models](#Steps-To-Verify-Deployed-Tosca-Models)
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
    sudo systemctl stop docker 
    sudo systemctl start docker
    sudo systemctl status docker
    sudo chmod 777 /var/run/docker.sock
    ```
    Make sure docker is installed properly by running following command :		
    ```sh
    docker info
    ```	
  - Clone the messageservice folder:
    ```sh
    mkdir ~/local-dmaap
    git clone https://gerrit.onap.org/r/dmaap/messagerouter/messageservice --branch frankfurt
    ```
    
    /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose/docker-compose.yaml	
    
    Should Include Following Line:
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
	```
	
- **Demo server:**

  - Create AWS VM (demo_server) with following specifications and SSH it using putty:
    
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
    sudo systemctl stop docker 
    sudo systemctl start docker
    sudo systemctl status docker
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
	
## Building Tosca Model Csars

- **List Of Models And Their Summary:**
	
	To Build the csar of each model we have to first clone the tosca-models on Demo Server from github for that use the below link and store it on /home/ubuntu.
	```sh
	git clone https://github.com/customercaresolutions/tosca-models 
	```
	Run following commands to build model csar.
	
  - SDWAN:
    Go to the cd home/ubuntu/tosca-models/cci/sdwan and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```  
  - FW:
    Go to the cd home/ubuntu/tosca-models/cci/firewall and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - NONRTRIC:
    Go to the cd home/ubuntu/tosca-models/cci/nonrtric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - RIC:
    Go to the cd home/ubuntu/tosca-models/cci/ric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP:
    Go to the cd home/ubuntu/tosca-models/cci/qp and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP-DRIVER:
    Go to the cd home/ubuntu/tosca-models/cci/qp-driver and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - TS:
    Go to the cd home/ubuntu/tosca-models/cci/ts and then run the build.sh file as follows:
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

- **Steps for Building Images/using pre-build Images and starting docker containers:**

	Login into the demo_server and perform the steps as follows:
	
  - clone puccini:
  
    ```sh
    git clone https://github.com/customercaresolutions/puccini
    ```
	
  - To use pre-build tosca images:
  
    - Make following changes in puccini/docker-compose.yml of puccini
	    
		```sh
	    orchestrator:
		    image: 172.31.27.186:5000/tosca-so:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    compiler:
		    image: 172.31.27.186:5000/tosca-compiler:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    workflow:
		    image: 172.31.27.186:5000/tosca-workflow:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    policy:
		    image: 172.31.27.186:5000/tosca-policy:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    gawp:
		    image: 172.31.27.186:5000/tosca-gawp:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log
		```
		 
  - To build new tosca images:
  
    - Make following changes in puccini/docker-compose.yml of puccini
	    
		```sh
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
		```		 

	- Modify ~/puccini/dvol/config/application.cfg as follows:					
			
		  [remote]
		  remoteHost={IP_of_server}
		  remotePort=22
		  remoteUser=ubuntu
		  remotePubKey=/opt/app/config/cciPrivateKey
		  msgBusURL={IP_OF_DMaap_Server}:3904
		  schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt
				  
	  Note1:  IP_of_server if we want to deploy sdwan, firewall then use IP_of_demo_server and if we want to deploy firewall, sdwan & oran models then use IP_of_bonap_server.   
	  Note2: cciPrivateKey is the Key to login/ssh into AWS.   
	  
	- Copy files as given follows:
	  - Copy all csar(sdwan.csar, firewall.csar etc) to ~/puccini/dvol/models/
	  - Copy cciPrivateKey  to ~/puccini/dvol/config/
	  - Copy /puccini/config/TOSCA-Dgraph-Schema.txt to /puccini/dvol/config/

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
    ubuntu@ip-10-0-0-220:~/puccini$ docker ps -a  
    CONTAINER ID   IMAGE                       COMMAND              CREATED         STATUS                     PORTS                                                                                                                             NAMES
    315aa3b27684   cci/tosca-policy:latest     "./tosca-policy"     9 minutes ago   Exited (2) 9 minutes ago                                                                                                                                     puccini_policy_1
    bd4cc551e0fc   cci/tosca-workflow:latest   "./tosca-workflow"   9 minutes ago   Up 9 minutes               0.0.0.0:10020->10020/tcp, :::10020->10020/tcp                                                                                     puccini_workflow_1
    05b53b9d8fb5   cci/tosca-so:latest         "./tosca-so"         9 minutes ago   Up 9 minutes               0.0.0.0:10000->10000/tcp, :::10000->10000/tcp                                                                                     puccini_orchestrator_1
    b532f72f21d1   cci/tosca-gawp:latest       "./tosca-gawp"       9 minutes ago   Up 9 minutes               0.0.0.0:10040->10040/tcp, :::10040->10040/tcp                                                                                     puccini_gawp_1 
    2813f70abcc3   cci/tosca-compiler:latest   "./tosca-compiler"   9 minutes ago   Up 9 minutes               0.0.0.0:10010->10010/tcp, :::10010->10010/tcp                                                                                     puccini_compiler_1
    289da3c4bafc   dgraph/standalone:latest    "/run.sh"            9 minutes ago   Up 9 minutes               0.0.0.0:8000->8000/tcp, :::8000->8000/tcp, 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:9080->9080/tcp, :::9080->9080/tcp   puccini_dgraphdb_1
    ```
## Summary Of Options Available

  Following are the short description of various options in request body while creating service instance.(TBD)

- list-steps-only:
 
  There is option called "list-steps-only" key-pair present in API body If the "list-steps-only" value is "true" means we are just list the steps of deployment and if value of it   is "false" it means we deploy model on AWS.
  
- execute-workflow:


## Deploying Tosca Models

   There are two ways to deploy tosca models one is Docker Containers and the other is using ONAP OOM environment. 
    
  - **Docker Containers:** 
   
    There are several models in puccini tosca as follows:
	
	**#Sdwan** 
	
	**#Firewall**
	
	**#Oran (Nonrtric, Ric, Qp, Qp-driver, Ts)** 

	- Store model in Dgraph:
	  
	  ```sh
	  POST http://{IP_OF_bonap_server}:10010/compiler/model/db/save
	  {
		  "url":"/opt/app/models/<ModelName>.csar",
		  "output": "./<ModelName>-dgraph-clout.json",
		  "resolve":true,
		  "quirks": ["data_types.string.permissive"],
		  "inputs":"",
		  "inputsUrl": ""
	  }
	  ```  		 
	  For sdwan use following:
	  ```sh
		{
		  "url":"/opt/app/models/firewall.csar",
		  "output": "./firewall-dgraph-clout.json",
		}
	  ```	
	  
	- Create Service Instances Without Deployment:
	
	  Note: To  Deploy models while create instance ("list-steps-only":true and "execute-policy":false)
	
	  For Sdwan, Firewall, Nonrtric, Ric, qp, qp-driver, ts:
	  ```sh			
	  POST http://{IP_OF_bonap_server}:10000/bonap/templates/createInstance
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
	  POST http://{IP_OF_bonap_server}:10000/bonap/templates/createInstance
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

	- ExecuteWorkfow Service without Deployment:
	  
	  Note: ExecuteWorkfow API Without Deploy("list-steps-only":true)
	  
	  ```sh
          POST http://{IP_OF_bonap_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
	  {
	      "list-steps-only": true,
	      "execute-policy": false
	  }
	  ```		 

	- ExecuteWorkfow Service with Deployment:
	  
	  Note: ExecuteWorkfow API With Deploy("list-steps-only":false)
	   
	  ```sh	
          POST http://{IP_OF_bonap_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
	  {
              "list-steps-only": false,
	      "execute-policy": true
	  }
	  ```
	  
	- Execute Policy: 
	  
	  ```sh
	  POST http://{IP_OF_bonap_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
	  ```
	  
        - Stop Policy:
         
	  ```sh
	  DELETE http://{IP_OF_bonap_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
   	  ```
	  
        - Get Policies:
         
	  ```sh
	  GET http://{IP_OF_bonap_server}:10000/bonap/templates/<InstanceName>/policies
	  ```
	  
  - **ONAP OOM:**
  
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
