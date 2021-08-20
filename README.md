# GIN 
Table of contents
=================
<!--ts-->
   * [Introduction](#Introduction)
   * [Pre Deployment Steps](#Pre-Deployment-Steps)
   * [Building Tosca Model Csars](#Building-Tosca-Model-Csars)
   * [Building images and started docker containers of puccini tosca components](#Building-images-and-started-docker-containers-of-puccini-tosca-components)
   * [Deploying Tosca Models](#Deploying-Tosca-Models)
   * [Summary Of Options Avaiable](#Summary-Of-Options-Avaiable)
   * [Steps To Verify Deloyed Tosca Models](#Steps-To-Verify-Deloyed-Tosca-Models)
<!--te-->  

## Introduction(TBD)

  This page is help us to deploy all tosca models using Docker Conatiner, ONAP OOM and also help to Verfiy models are properly deploy or not.

## Pre Deployment Steps
- **DMaaP Server:**

  - Create AWS VM (DMaaP server) in Ohio region with following specifications and SSH it using Putty:
    
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
    Make sure docker is install properly by running below command :		
    ```sh
    docker info
    ```	
  - Clone the messageservice folder:
    ```sh
    mkdir ~/local-dmaap
    git clone https://gerrit.onap.org/r/dmaap/messagerouter/messageservice --branch frankfurt
    ```
    
    Made changes in docker-compose.yaml file:
    
    /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose/docker-compose.yaml	
    
    After Changes:
    ```sh          
    image: 172.31.27.186:5000/dmaap:localadapt_0.1
    ```		
  - To Start DMaaP Server:
    ```sh
    cd /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose
    docker-compose up -d
    ```
  - Verify DMaap Server is Deploy:
  
	To verfiy DMaap Server is Deploy or not run the command as follows and check wither all the conatiner should  
    be UP.
	
	```sh
	ubuntu@message_router:~/local-dmaap/messageservice/target/classes/docker-compose$ docker ps -a
	CONTAINER ID   IMAGE                                              COMMAND                  CREATED         STATUS         PORTS                                                           NAMES
	a234f9f984dd   dmaap:localadapt                                   "sh startup.sh"          6 seconds ago   Up 5 seconds   0.0.0.0:3904-3906->3904-3906/tcp, :::3904-3906->3904-3906/tcp   dockercompose_dmaap_1
	8058f11e9f57   nexus3.onap.org:10001/onap/dmaap/kafka111:1.0.4    "/etc/confluent/dock…"   7 seconds ago   Up 6 seconds   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp, 9093/tcp             dockercompose_kafka_1
	a93fcf78bcb9   nexus3.onap.org:10001/onap/dmaap/zookeeper:6.0.3   "/etc/confluent/dock…"   9 seconds ago   Up 6 seconds   2888/tcp, 0.0.0.0:2181->2181/tcp, :::2181->2181/tcp, 3888/tcp   dockercompose_zookeeper_1
	```
	
	There is another way to Verify DMaap is Deploy or Not. 
	
    ```sh
	curl -X GET "http://{IP_OF_DMaap_Server}:3904/topics" 
	```
	
- **Demo server:**

  - Create AWS VM(demo_server) with following specifications and SSH it using Putty:
    
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

    Make sure docker is insatll properly by running below command :
		
    ```sh
    docker info
    ```
	
- **Oran Servers:**(TBD)

  - To Set up the oran Servers on AWS follow the wiki page as sollows:

    ```sh	
    http://54.236.224.235/wiki/index.php/Steps_for_setting_up_clustering_for_ORAN_models
    ```
	
## Building Tosca Model Csars

- **List Of Models And Their Summary:**
	
	To Build the csar of each model we have to first clone the tosca-models from github for that use the below link and store it on /home/ubuntu.
	```sh
	gitclone https://github.com/customercaresolutions/tosca-models 
	```
	After cloning  perform the step as follows.
	
  - SDWAN:
    Go to the home/ubuntu/tosca-models/cci/sdwan and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```  
  - FW:
    Go to the home/ubuntu/tosca-models/cci/firewall and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - NONRTRIC:
    Go to the home/ubuntu/tosca-models/cci/nonrtric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - RIC:
    Go to the home/ubuntu/tosca-models/cci/ric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP:
    Go to the home/ubuntu/tosca-models/cci/qp and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP-DRIVER:
    Go to the home/ubuntu/tosca-models/cci/qp-driver and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - TS:
    Go to the home/ubuntu/tosca-models/cci/ts and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```

## Building images and started docker containers of puccini tosca components
- **List of components and their summary:**(TBD)
  - TOSCA_SO:
  - TOSCA_COMPILER:
  - TOSCA_WORKFLOW:
  - TOSCA_POLICY:
  - TOSCA_GAWP:

- **Steps to Building Images and started docker containers:**

	Login into the demo_server and Perform the steps as follows:
	
  - clone puccini:
    ```sh
    git clone https://github.com/customercaresolutions/puccini
    ```
  - Made following changes in puccini:

	- Puccini/docker-compose.yml:
		
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
	  
	  Verify 'DMaaP' VM on AWS N.Virginia Region should be in running state and DMAAP running on this VM.

	- Modify ~/puccini/dvol/config/application.cfg as below:					
			
		  [remote]
		  remoteHost={IP_OF_bonap_server}
		  remotePort=22
		  remoteUser=ubuntu
		  remotePubKey=/opt/app/config/cciPrivateKey
		  msgBusURL={IP_OF_DMaap_Server}:3904
		  schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt
				  
	  Note: IP_OF_demo_server is VM which we created at start. 
		About cciPrivateKey:- cciPrivateKey is the Key or we can say Password to login/ssh into AWS VM and this Key is avaiable locally.  
		About application.cfg:- As we see the {IP_OF_bonap_server} in application.cfg this is come from the Oran Server which we setup as a Pre Deployment Steps.
	- Copy files as given below:
	  - Copy all csar(sdwan.csar, firewall.csar etc) to ~/puccini/dvol/models/
	  - Copy cciPrivateKey  to ~/puccini/dvol/config/
	  - Copy /puccini/config/TOSCA-Dgraph-Schema.txt to /puccini/dvol/config/

  - Build Docker images:
    ```sh
    cd ~/puccini
    docker-compose up -d
    ```

  - Check wither the images are created:
    ```sh
    docker images -a
    ```
	
  - verify all docker container should be in running state:
    ```sh
    docker ps -a
    ```
	
  - Here we check the *STATUS* of each Container should be UP.
    
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
## Summary Of Options Avaiable

  Following are the short description of various options in request body while creating service instance.(TBD)

- list-steps-only:
 
  There is option called "list-steps-only" key-pair present in API body If the "list-steps-only" value is "true" means we are just list the steps of deployment and if value of it   is "false" it means we deploy model on AWS.
  
- execute-workflow:


## Deploying Tosca Models
- **Steps To Deploy:**
 
    There are two way to deploy tosca models 
    
    *1.Docker Containers* *2.ONAP OOM* 
    
    and following is the detail explanation
    
  - **Docker Containers:** 
   
    There are several models in puccini tosca as follows:
	
	*Sdwan*, *Firewall*, *Oran (Nonrtric, Ric, Qp, Qp-driver, Ts)* 
	
	To Test the models we have to first store the model in Dgraph for that we have to run the below API through the POASTMAN.

	- Store Model In Dgraph:
	  
	  ```sh
	  POST http://{IP_OF_bonap_server}:10010/compiler/model/db/save
	  	{
		  "url":"/opt/app/models/<ModelName>.csar",
		  "resolve":true,
		  "coerce":false,
		  "quirks": ["data_types.string.permissive"],
		  "output": "./<ModelName>-dgraph-clout.json",
		  "inputs":"",
		  "inputsUrl": ""
		}
	  ```  		 
	  e.g:
	  ```sh
	  -- Sdwan:
		{
		  "url":"/opt/app/models/firewall.csar",
		  "output": "./firewall-dgraph-clout.json",
		}
	  --Firewall:
		{
		  "url":"/opt/app/models/sdwan.csar",
		  "output": "./sdwan-dgraph-clout.json",
		}
	  --Nonrtric:	
		{
		  "url":"/opt/app/models/nonrtric.csar",
		  "output": "./nonrtric-dgraph-clout.json",
		}
	  --Ric:	
		{
		  "url":"/opt/app/models/ric.csar",
		  "output": "./ric-dgraph-clout.json",
		}
	  --Qp:
		{
		  "url":"/opt/app/models/qp.csar",
		  "output": "./qp-dgraph-clout.json",
		}
	  --Qp-driver:
		{
		  "url":"/opt/app/models/qp-driver.csar",
		  "output": "./qp-driver-dgraph-clout.json",
		}
	  --Ts:	
		{
		  "url":"/opt/app/models/ts.csar",
		  "output": "./ts-dgraph-clout.json",
		}
		
	  ```	
	  
	- Create Service Instances Without Deployment:
	
	  Note: To Deploy models While CreateInstance("list-steps-only":true and "execute-policy":false)
	
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
	  
      Use Following InputUrl and Service in Api Body For:
		  
	  ```sh
	  --Firewall:
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml",
	    "execute-policy":false
	  --Sdwan:
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml",
	    "execute-policy":false
	  --Ric:
	  	"inputs":  {
			"helm_version":"2.17.0"
			},
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/ric.csar!/ric.yaml",
		"execute-policy":false
	  --Nonrtric:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/nonrtric.csar!/nonrtric.yaml",
		"execute-policy":false
	  --Qp:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/qp.csar!/qp.yaml",
		"execute-policy":false
	  --Qp-driver:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/qp-driver.csar!/qp-driver.yaml",
		"execute-policy":false
	  --Ts:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/ts.csar!/ts.yaml",
		"execute-policy":false
	  ```

	- Create Service Instances With Deployment:
	  
	  Note: To Deploy models While CreateInstance("list-steps-only":false and "execute-policy":true)
	
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
	  
      Use Following InputUrl and Service in Api Body For:

	  ```sh
	  --Firewall:
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml",
	    "execute-policy":true
	  --Sdwan:
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml",
	    "execute-policy":true
	  --Ric:
	  	"inputs":  {
			"helm_version":"2.17.0"
			},
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/ric.csar!/ric.yaml",
		"execute-policy":true,
	  --Nonrtric:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/nonrtric.csar!/nonrtric.yaml",
		"execute-policy":true
	  --Qp:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/qp.csar!/qp.yaml",
		"execute-policy":true
	  --Qp-driver:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/qp-driver.csar!/qp-driver.yaml",
		"execute-policy":true
	  --Ts:
	  	"inputs":"",
	  	"inputsUrl":"",
	        "service":"zip:/opt/app/models/ts.csar!/ts.yaml",
		"execute-policy":true
	  ```

	- ExecuteWorkfow Service without Deployment:
	  
	  Note : ExecuteWorkfow API Without Deploy("list-steps-only":true)
	  
	  ```sh
          POST http://{IP_OF_bonap_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
	  {
		"list-steps-only": true,
		"execute-policy": false
	  }
	  ```		 

	- ExecuteWorkfow Service with Deployment:
	  
	  Note : ExecuteWorkfow API With Deploy("list-steps-only":false)
	   
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
  
## Steps To Verify Deloyed Tosca Models 
 
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
