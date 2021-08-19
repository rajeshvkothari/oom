# GIM

## Pre-deployment steps
- DCAE&DMAP server:

   - Create AWS VM(DMAAP&DCAE) in Ohio region with following specifications and SSH it using Putty:
   
		Image: ubuntu-18.04
		InstanceType: t2.large
		Storage: 80GB
		KeyPair : cciPublicKey
    - Setup Docker on DMAAP&DCAE:
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
   - Clone the messageservice folder
     ```sh
     mkdir ~/local-dmaap
     git clone https://gerrit.onap.org/r/dmaap/messagerouter/messageservice --branch frankfurt
    ``
    Made changes in docker-compose.yaml file:
    /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose/docker-compose.yaml	 
    After Chnages:
		image: 172.31.27.186:5000/dmaap:localadapt_0.1	
   - TO the Start dmaap Server:
     ```sh
     cd /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose
     docker-compose up -d
     ```
- Demo server:
   - Create AWS VM(demo_server) with following specifications and SSH it using Putty:
		
		Image: ubuntu-18.04
		InstanceType: t2.large
		Storage: 80GB
		KeyPair : cciPublicKey
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

## Building images for puccini tosca components
- List of components and their summary:
  - TOSCA_SO:
  - TOSCA_COMPILER:
  - TOSCA_WORKFLOW:
  - TOSCA_POLICY:
  -TOSCA_GAWP:

- Steps to build each component:
  - clone puccini:
```sh
git clone https://github.com/customercaresolutions/puccini
```
  - Made following changes in puccini:
    - puccini\docker-compose.yml:
			 Uncomment following part:
			 
			   Before:
				 orchestrator:
				   #    build:
				   #      context: .
				   #      dockerfile: Dockerfile.so.multistage
						volumes:
						  -  ../workdir/dvol/config:/opt/app/config
						  -  ../workdir/dvol/models:/opt/app/models
						  -  ../wrokdir/dvol/data:/opt/app/data
						  -  ../workdir/dvol/log:/opt/app/log	
				 compiler:
				   #     build:
				   #       context: .
				   #       dockerfile: Dockerfile.compiler.multistage
						 volumes:
						   -  ../workdir/dvol/config:/opt/app/config
						   -  ../workdir/dvol/models:/opt/app/models
						   -  ../wrokdir/dvol/data:/opt/app/data
						   -  ../workdir/dvol/log:/opt/app/log	 
				 workflow:
				   #    build:
				   #      context: .
				   #      dockerfile: Dockerfile.workflow.multistage
						volumes:
						  -  ../workdir/dvol/config:/opt/app/config
						  -  ../workdir/dvol/models:/opt/app/models
						  -  ../workdir/dvol/data:/opt/app/data
						  -  ../workdir/dvol/log:/opt/app/log
				 policy:
				   #    build:
				   #      context: .
				   #      dockerfile: Dockerfile.policy.multistage
						volumes:
						  -  ../workdir/dvol/config:/opt/app/config
						  -  ../workdir/dvol/models:/opt/app/models
						  -  ../workdir/dvol/data:/opt/app/data
						  -  ../workdir/dvol/log:/opt/app/log
				 gawp:
				   #    build:
				   #      context: .
				   #      dockerfile: Dockerfile.gawp.multistage
						volumes:
						  -  ../workdir/dvol/config:/opt/app/config
						  -  ../workdir/dvol/models:/opt/app/models
						  -  ../workdir/dvol/data:/opt/app/data
						  -  ../workdir/dvol/log:/opt/app/log
				
			   After:
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
				 
Verify 'DMAAP&DCAE' VM on AWS N.Virginia Region should be in running state and DMAAP running on this VM
    - Modify ~/puccini/dvol/config/application.cfg:
					
	Before:
		[remote]
		remoteHost=bonap-server.com
		remotePort=22
		remoteUser=ubuntu
		remotePubKey=/opt/app/config/ohio-key-pair.pem
		msgBusURL=mwssage-router:3904
		schemaFilePath=../config/TOSCA-Dgraph-schema.txt
		
		
	After:
		[remote]
		remoteHost={IP_OF_demo_server}
		remotePort=22
		remoteUser=ubuntu
		remotePubKey=/opt/app/config/cciPrivateKey
		msgBusURL={IP_OF_DMAAP&DCAE}:3904
		schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt
				  
Note:IP_OF_demo_server is VM which we created at start
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
	
Here we check that status of each container should be UP not Exited.
	
	e.g:
	ubuntu@ip-10-0-0-220:~/puccini$ docker ps -a
	CONTAINER ID   IMAGE                       COMMAND              CREATED         STATUS                     PORTS                                                                                                                             NAMES
	315aa3b27684   cci/tosca-policy:latest     "./tosca-policy"     9 minutes ago   Exited (2) 9 minutes ago                                                                                                                                     puccini_policy_1
	bd4cc551e0fc   cci/tosca-workflow:latest   "./tosca-workflow"   9 minutes ago   Up 9 minutes               0.0.0.0:10020->10020/tcp, :::10020->10020/tcp                                                                                     puccini_workflow_1
	05b53b9d8fb5   cci/tosca-so:latest         "./tosca-so"         9 minutes ago   Up 9 minutes               0.0.0.0:10000->10000/tcp, :::10000->10000/tcp                                                                                     puccini_orchestrator_1
	b532f72f21d1   cci/tosca-gawp:latest       "./tosca-gawp"       9 minutes ago   Up 9 minutes               0.0.0.0:10040->10040/tcp, :::10040->10040/tcp                                                                                     puccini_gawp_1
	2813f70abcc3   cci/tosca-compiler:latest   "./tosca-compiler"   9 minutes ago   Up 9 minutes               0.0.0.0:10010->10010/tcp, :::10010->10010/tcp                                                                                     puccini_compiler_1
	289da3c4bafc   dgraph/standalone:latest    "/run.sh"            9 minutes ago   Up 9 minutes               0.0.0.0:8000->8000/tcp, :::8000->8000/tcp, 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:9080->9080/tcp, :::9080->9080/tcp   puccini_dgraphdb_1

  - Push images to repository:

      tosca-so:
         docker tag cci/tosca-so:latest <repository_name>/tosca-so:<version>
         docker push <repository_name>/tosca-so:<version>
      tosca-compiler:
         docker tag cci/tosca-compiler:latest <repository_name>/tosca-compiler:<version>
         docker push <repository_name>/tosca-compiler:<version>
      tosca-workflow:	
         docker tag cci/tosca-workflow:latest <repository_name>/tosca-workflow:<version>
         docker push <repository_name>/tosca-workflow:<version>
      tosca-policy:	
         docker tag cci/tosca-policy:latest <repository_name>/tosca-policy:<version>
         docker push <repository_name>/tosca-policy:<version>
	  tosca-gawp:	 
         docker tag cci/tosca-gawp:latest <repository_name>/tosca-gawp:<version>
         docker push <repository_name>/tosca-gawp:<version>

## Building model csars

- List of models and their summary

  - SDWAN:
Go to the C:/tosca-models/cci/sdwan and then run the build.sh file as below:
```sh
./build.sh
```  
  - FW:
Go to the C:/tosca-models/cci/firewall and then run the build.sh file as below:
```sh
./build.sh
```
  - NONRTRIC:
Go to the C:/tosca-models/cci/nonrtric and then run the build.sh file as below:
```sh
./build.sh
```
  - RIC:
Go to the C:/tosca-models/cci/ric and then run the build.sh file as below:
```sh
./build.sh
```
  - QP:
Go to the C:/tosca-models/cci/qp and then run the build.sh file as below:
```sh
./build.sh
```
  - QP-DRIVER:
Go to the C:/tosca-models/cci/qp-driver and then run the build.sh file as below:
```sh
./build.sh
```
  - TS:
Go to the C:/tosca-models/cci/ts and then run the build.sh file as below:
```sh
./build.sh
```

## Steps to Deploying puccini components:
	
- Clone the latest puccini and tosca-model from below links and copy those folder in C:/ drive :

	git clone https://github.com/customercaresolutions/puccini
	git clone https://github.com/customercaresolutions/tosca-models
	
Create a Workspace in Visual Stdio and and both above folder into workspace.

- Start dgraph => clean all data from dgraph

- Open new terminal with Git Bash with puccini/scripts folder to build our .exe: 
```bash
sh build
```

- Open new seprate terminal for puccini components and run those as below:

	for tosca-so:
	so
	for tosca-workflow:
	workflow
	for tosca-policy:
	policy
	for tosca-gawp:
	gawp 

- Store the model in Dgraph using persist and then send the below API through POSTMAN to deploy firewall,sdwan and oran model:

Firewall:

	Persist model:
	cd C:/
	puccini-tosca compile tosca-models/cci/firewall.csar --output tosca-models/cci/firewallCsarClout.json --format json --persit
	
	POST http://localhost:10000/bonap/templates/createInstance
		{
			"name" : "<instance_name>",
			"output": "../../workdir/firewall-dgraph-clout.yaml",
			"inputs": "",
			"inputsUrl":"zip:/tosca-models/cci/firewall.csar!/firewall/inputs/aws.yaml",
			"generate-workflow":true,
			"execute-workflow":true,
			"list-steps-only":false,
			"execute-policy": true,
			"service":"zip:/tosca-models/cci/firewall.csar!/firewall/firewall_service.yaml",
			"coerce":false
		}
		
Sdwan:

	Persist model:
	cd c:/
	puccini-tosca compile tosca-models/cci/sdwan.csar --output tosca-models/cci/sdwanCsarClout.json --format json --persist
	
	POST http://localhost:10000/bonap/templates/createInstance
		{
			"name" : "<instance_name>",
			"output": "./sdwan-dgraph-clout.json",
			"inputs": "",
			"inputsUrl":"zip:/tosca-models/cci/sdwan.csar!/sdwan/inputs/aws.yaml",
			"generate-workflow":true,
			"execute-workflow":true,
			"list-steps-only":false,
			"execute-policy": true,
			"service":"zip:/tosca-models/cci/sdwan.csar!/sdwan/sdwan_service.yaml"
		}
Nonrtric:
	
	Persist model:
	cd C:/
	puccini-tosca compile tosca-models/cci/nonrtric.csar --output tosca-models/cci/nonrtricCsarClout.json --format json --persist

	POST http://localhost:10000/bonap/templates/createInstance
	   {
		"name" : "nonrtric_inst101",
		"output": "./nonrtric-dgraph-clout.json",
		"inputs": "",
		"inputsUrl":"",
		"generate-workflow":true,
		"execute-workflow":true,
		"list-steps-only":false,
		"execute-policy": false,
		"service":"zip:/tosca-models/cci/nonrtric.csar!/nonrtric.yaml",
		"csarUrl":"file:/tosca-models/cci/nonrtric.csar",
		"coerce":true
		}
Ric:

	Persist model:
	cd C:/
	puccini-tosca compile tosca-models/cci/ric.csar --output tosca-models/cci/ricCsarClout.json --format json --persist -i helm_version="2.17.0"
	
	POST http://localhost:10000/bonap/templates/createInstance\
		 {
			"name" : "<instance_name>",
			"output": "./ric-dgraph-clout.json",
			"inputs":  {
				"helm_version":"2.17.0"
				},
			"inputsUrl":"",
			"generate-workflow":true,
			"execute-workflow":true,
			"list-steps-only":false,
			"execute-policy": false,
			"service":"zip:/tosca-models/cci/ric.csar!/ric.yaml"
		}
Qp:

	Persist model:
	cd C:/
	puccini-tosca compile tosca-models/cci/qp.csar --output tosca-models/cci/qpCsarClout.json --format json --persist

	POST http://localhost:10000/bonap/templates/createInstance
	   {
			"name" : "<instance_name>",
			"output": "./qp-dgraph-clout.json",
			"inputs": "",
			"inputsUrl":"",
			"generate-workflow":true,
			"execute-workflow":true,
			"list-steps-only":false,
			"execute-policy": false,
			"service":"zip:/tosca-models/cci/qp.csar!/qp.yaml",
			"csarUrl":"file:/tosca-models/cci/qp.csar",
			"coerce":true
		}
Qp-driver:
	
	Persist model:
	cd C:/
	puccini-tosca compile tosca-models/cci/qp-driver.csar --output tosca-models/cci/qpDriverCsarClout.json --format json --persist	 

	POST http://localhost:10000/bonap/templates/createInstance
	   {
			"name" : "<instance_name>",
			"output": "./qp-driver-dgraph-clout.json",
			"inputs": "",
			"inputsUrl":"",
			"generate-workflow":true,
			"execute-workflow":true,
			"list-steps-only":false,
			"execute-policy": false,
			"service":"zip:/tosca-models/cci/qp-driver.csar!/qp-driver.yaml",
			"csarUrl":"file:/tosca-models/cci/qp-driver.csar",
			"coerce":true
		}
Ts:

	Persist model:
	cd C:/
	puccini-tosca compile tosca-models/cci/ts.csar --output tosca-models/cci/tsCsarClout.json --format json --persist
	
	POST http://localhost:10000/bonap/templates/createInstance
	   {
		"name" : "<instance_name>",
		"output": "./ts-dgraph-clout.json",
		"inputs": "",
		"inputsUrl":"",
		"generate-workflow":true,
		"execute-workflow":true,
		"list-steps-only":false,
		"execute-policy": false,
		"service":"zip:/tosca-models/cci/ts.csar!/ts.yaml",
		"csarUrl":"file:/tosca-models/cci/ts.csar",
		"coerce":true
		}

## Summary of options avaiable

- list-steps, execute-workflow:

There is option called "list-steps-only" key-pair present in API body If the "list-steps-only" value is "true" means we are just list the steps of deployment and if value of it is "false" it means we deploy model on AWS.

- workflow engine selection (built-in/argo/argo-container-set):

- application.cfg:

In application.cfg file we menation all the puccini tosca components.
 
## Deploying models using docker images
- Steps to deplpoy:
  - Docker images: 
	There are total seven model puccini tosca Sdwan,Firewall, Oran(Nonrtric,Ric,Qp,Qp-driver,ts). To Test the model we have to first store the model in Dgraph for that we have to run the below API through the POASTMAN and also run below createInstance,ExecuteWorkfow API to test them. To test the oran model we have to first create a oran setup on AWS. So to step up the oran cluster follow the below wiki page:

	http://54.236.224.235/wiki/index.php/Steps_for_setting_up_clustering_for_ORAN_models

	To access the above wiki page credentials are
	
	Username: Divan
	Passowrd: wikiaccess

	  - Store Model In Dgraph:
	
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
			 
		e.g:
			{
				"url":"/opt/app/models/firewall.csar",
				"output": "./firewall-dgraph-clout.json",
			}			 
			{
				"url":"/opt/app/models/sdwan.csar",
				"output": "./sdwan-dgraph-clout.json",
			}
			
		Note: Deploy Model While CreateInstance("list-steps-only":false and "execute-policy": true)

      - Create Instances With Deploy:
	
		For Sdwan,Firewall:
				
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
					"coerce":false
				}
				
		Use Following InputUrl And Service In Api Body For:

			--Firewall:
					"inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
					"service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml",
			--Sdwan:
					"inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
					"service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml",
				  
			

		Note : ExecuteWorkfow Deploy model 

      - ExecuteWorkfow API With Deploy("list-steps-only": false):
	
		POST http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
			{
				"list-steps-only": false,
				"execute-policy": true
			}
			
      - Execute Policy: 
	
		POST http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
	 
      - Stop Policy:
	
		DELETE http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
   
      - Get Policies:
	
		GET http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policies  
  - ONAP OOM:
  
- Steps to verify: Through below steps help us to verfiy Firewall,Sdwan,Oran(nonrtric,ric,qp,qp-driver,ts) model is deploy or not.
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
          {"instances":null,"name":"trafficxapp","status":"deployed","version":"1.0"}	  		   
	- Compare tosca-models/cci/tsCsarClout.json with puccini/so/ts-dgraph-clout.json using compare tool.
