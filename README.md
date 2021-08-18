# Puccini Testing

## Pre-deployment steps
1.DCAE&DMAP server:
	
1] Create AWS VM(DCAE&DMAP) with following specifications and SSH it using Putty:
Image: ubuntu-18.04
InstanceType: t2.large
Storage: 80GB
KeyPair : cciPublicKey
	
2] Setup Docker on DCAE&DMAP
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
2.Demo server:
	
1] Create AWS VM(demo_server) with following specifications and SSH it using Putty:
Image: ubuntu-18.04
InstanceType: t2.large
Storage: 80GB
KeyPair : cciPublicKey
	  
2] Setup Docker on demo_server
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
1.List of components and their summary:
	
1]TOSCA_SO:
		
2]TOSCA_COMPILER:
	
3]TOSCA_WORKFLOW:
	
4]TOSCA_POLICY:
	
5]TOSCA_GAWP:

2.Steps to build each component:

1]clone puccini:
```sh
	git clone https://github.com/customercaresolutions/puccini
```
		
2]Made following changes in puccini:

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

3]Build Docker images:
```sh
cd ~/puccini
docker-compose up -d
```

4]Check wither the images are created:
```sh
docker images -a
```
	
5]verify all docker container should be in running state:
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

## Building model csars

- List of models and their summary

1.SDWAN: 
  
Go to the C:/tosca-models/cci/sdwan and then run the build.sh file as below:
```sh
./build.sh
```
  
2.FW:
  
Go to the C:/tosca-models/cci/firewall and then run the build.sh file as below:
```sh
./build.sh
```
  
3.NONRTRIC:
  
Go to the C:/tosca-models/cci/nonrtric and then run the build.sh file as below:
```sh
./build.sh
```
  
4.RIC:
  
Go to the C:/tosca-models/cci/ric and then run the build.sh file as below:
```sh
./build.sh
```
  
5.QP:
  
Go to the C:/tosca-models/cci/qp and then run the build.sh file as below:
```sh
./build.sh
```
  
6.QP-DRIVER:
  
Go to the C:/tosca-models/cci/qp-driver and then run the build.sh file as below:
```sh
./build.sh
```
  
7.TS:
  
Go to the C:/tosca-models/cci/ts and then run the build.sh file as below:
```sh
./build.sh
```

## Deploying puccini components
- Steps

## Various methods of deployment/testing

1.Docker Images:

2.ONAP OOM

## Summary of options avaiable

1.list-steps, execute-workflow etc

2.workflow engine selection (built-in/argo/argo-container-set)

3.application.cfg
 
## Deploying models using docker images

- Steps to deploy and verify

1.SDWAN:
  
2.FW:
  
3.NONRTRIC:
  
4.RIC:
  
5.QP:
  
6.QP-DRIVER:
  
7.TS:
  
