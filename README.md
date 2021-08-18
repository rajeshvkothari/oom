# Testing Puccini Through Docker Containers

## Setup the ubuntu

Start/create any ubuntu-18.04 machine Virtually or on AWS with any Name eg. Demo_server

## Setup Docker on ubuntu

```sh
	sudo apt update
	sudo apt install docker.io
	sudo apt  install docker-compose
	sudo systemctl stop docker 
	sudo systemctl start docker
	sudo chmod 777 /var/run/docker.sock
```

Make sure docker is insatll properly by running below command :

```sh
	docker info
```
	
## Steps for creating tosca images

	1.clone puccini:
```bash
git clone https://github.com/customercaresolutions/puccini
```
		
	2.Made following changes in puccini:

		 2.1)puccini\docker-compose.yml:
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
	 
				 
	Verify 'DMAAP&DCAE' VM on AWS N.Virginia Region should be in running state and DMAAP running on this VM.

			2.2)Modify ~/puccini/dvol/config/application.cfg:					
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
				  msgBusURL=54.196.51.118:3904
				  schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt
				  
	Note:IP_OF_demo_server is VM which we created at start

			2.3) Copy files as given below:
				- Copy all csar(sdwan.csar, firewall.csar etc) to ~/puccini/dvol/models/
				- Copy cciPrivateKey  to ~/puccini/dvol/config/
				- Copy /puccini/config/TOSCA-Dgraph-Schema.txt to /puccini/dvol/config/

	3.Build Docker images:
```sh
	cd ~/puccini
	docker-compose up -d
```

	4.Check wither the images are created:
```sh
	docker images -a
```
	
	5.verify all docker container should be in running state:
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


## Test the Tosca Models(firewall, sdwan and oran)

	To Test the firewall model we have to first store the model in Dgraph for that we have to run the below API through the POASTMAN and also run below createInstance,ExecuteWorkfow API too.

	1)Store Model In Dgraph:
	
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

	2)Create Instances With Deploy:
	
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
		  --nonrtric:
				  "inputsUrl":"zip:/opt/app/models/nonrtric.csar!/nonrtric/inputs/aws.yaml",
				  "service":"zip:/opt/app/models/nonrtric.csar!/nonrtric/nonrtric_service.yaml",
		  --ric:
				  "inputsUrl":"zip:/opt/app/models/ric.csar!/ric/inputs/aws.yaml",
				  "service":"zip:/opt/app/models/ric.csar!/ric/ric_service.yaml",
		  --qp:
				  "inputsUrl":"zip:/opt/app/models/qp.csar!/qp/inputs/aws.yaml",
				  "service":"zip:/opt/app/models/qp.csar!/qp/qp_service.yaml",
		  --qp-driver:
				  "inputsUrl":"zip:/opt/app/models/qp-driver.csar!/qp-driver/inputs/aws.yaml",
				  "service":"zip:/opt/app/models/qp-driver.csar!/qp-driver/qp-driver_service.yaml",
		  --ts:
				  "inputsUrl":"zip:/opt/app/models/ts.csar!/ts/inputs/aws.yaml",
				  "service":"zip:/opt/app/models/ts.csar!/ts/ts_service.yaml",
	

Note : ExecuteWorkfow Deploy model 

	3)ExecuteWorkfow API With Deploy("list-steps-only": false):
	
		POST http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/workflows/deploy
			{
			  "list-steps-only": false,
			  "execute-policy": true
			}
			
	4)Execute Policy: 
	
		POST http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
	 
	5)Stop Policy:
	
		DELETE http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
   
	6)Get Policies:
	
		GET http://{IP_OF_demo_server}:10000/bonap/templates/<InstanceName>/policies
