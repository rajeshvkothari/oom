# GIN 
Table of contents
=================
<!--ts-->
   * [Pre deployment steps](#Pre-deployment-steps)
   * [Building model csars](#Building-model-csars)
   * [Building images for puccini tosca components](#Building-images-for-puccini-tosca-components)
   * [Summary of options available](#Summary-of-options-available)
   * [Deploying models using docker images](#Deploying-models-using-docker-images)
<!--te-->  


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
	curl -X POST -H "Content-Type: application" -d '{"topicName":"cci_topic_1048","partitionCount":"1","replicationCount":"1","transactionEnabled":"false","description":"This is a test Topic"}' "http://{IP_OF_DMaap_server}:3904/topics/create" -o createtopic406.json
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

## Building Model Csars

- **List Of Models And Their Summary:**
	
	To Build the csar of each model we have to first clone the tosca-models from git clone https://github.com/customercaresolutions/tosca-models this link to the C: drive and perform the step as follows. 
	
  - SDWAN:
    Go to the C: /tosca-models/cci/sdwan and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```  
  - FW:
    Go to the C: /tosca-models/cci/firewall and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - NONRTRIC:
    Go to the C: /tosca-models/cci/nonrtric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - RIC:
    Go to the C: /tosca-models/cci/ric and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP:
    Go to the C: /tosca-models/cci/qp and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - QP-DRIVER:
    Go to the C: /tosca-models/cci/qp-driver and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```
  - TS:
    Go to the C: /tosca-models/cci/ts and then run the build.sh file as follows:
    ```sh
    ./build.sh
    ```

## Building images for puccini tosca components
- **List of components and their summary:**
  - TOSCA_SO:
  - TOSCA_COMPILER:
  - TOSCA_WORKFLOW:
  - TOSCA_POLICY:
  - TOSCA_GAWP:

- **Steps to build each component:**
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
	  
	  Verify 'DMAAP&DCAE' VM on AWS N.Virginia Region should be in running state and DMAAP running on this VM.

	- Modify ~/puccini/dvol/config/application.cfg as below:					
			
		  [remote]
		  remoteHost={IP_OF_demo_server}
		  remotePort=22
		  remoteUser=ubuntu
		  remotePubKey=/opt/app/config/cciPrivateKey
		  msgBusURL=54.196.51.118:3904
		  schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt
				  
	  Note: IP_OF_demo_server is VM which we created at start. 
		    About cciPrivateKey:- cciPrivateKey is the Key or we can say Password to login/ssh into AWS VM and this Key is avaiable locally.  
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

## Deploying models using docker images
- **Steps To Deploy:**
  - Building Images and Starting Container: 
   
    There are several models in puccini tosca as follows:
	*Sdwan*,*Firewall*, *Oran (Nonrtric, Ric, Qp, Qp-driver, Ts)* 
	To Test the model we have to first store the model in Dgraph for that we have to run the below API through the POASTMAN and also run below create Instance, ExecuteWorkfow API to test them. To test the oran model we have to first create a oran setup on AWS. So to step up the oran cluster follow the below wiki page:

    ```sh	
    http://54.236.224.235/wiki/index.php/Steps_for_setting_up_clustering_for_ORAN_models
    ```

	- Store Model In Dgraph:
	  
	  ```sh
	  POST http://{IP_OF_demo_server}:10010/compiler/model/db/save
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
		{
		  "url":"/opt/app/models/firewall.csar",
		  "output": "./firewall-dgraph-clout.json",
		}			 
		{
		  "url":"/opt/app/models/sdwan.csar",
		  "output": "./sdwan-dgraph-clout.json",
		}
	  ```			
          Note: Deploy Model While CreateInstance("list-steps-only":false and "execute-policy": true)

	- Create Instances With Deploy:
	
	  For Sdwan,Firewall:
	  ```sh			
	  POST http://{IP_OF_demo_server}:10000/bonap/templates/createInstance
	  {
		"name" : "<Instance_Name>",
		"output": "../../workdir/<ModelName>-dgraph-clout.yaml",
		"inputs": "",
		"inputsUrl":"<input_url_for_model>",
		"generate-workflow":true,
		"execute-workflow":true,
		"list-steps-only":false,
		"execute-policy": true,
		"service":"<service_url_for_model>",
	  }
	  ```			
          Use Following InputUrl and Service in Api Body For:
	  ```sh
	  --Firewall:
		"inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
		"service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml",
	  --Sdwan:
		"inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
	  	"service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml",
	  ```
          Note : ExecuteWorkfow Deploy model 

	- ExecuteWorkfow API With Deploy("list-steps-only": false):
	  ```sh
          POST http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
	  {
		"list-steps-only": false,
		"execute-policy": true
	  }
	  ```		
	- Execute Policy: 
	  
	  ```sh
	  POST http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
	  ```
        - Stop Policy:
	  ```sh
	  DELETE http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
   	  ```
        - Get Policies:
	  ```sh
	  GET http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policies
	  ```
	  
  - ONAP OOM:
  
- **Steps to verify:**
 
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
