# TICKCLAMP 
Table of contents
=================
<!--ts-->
   * [Introduction](#Introduction)
   * [Pre Deployment Steps](#Pre-Deployment-Steps)
     * [Tickbonap Servers](#Tickbonap-Servers)
     * [Creating Environment for Docker container based testing](#Creating-Environment-for-Docker-container-based-testing)
       * [DMaaP Server](#DMaaP-Server)
       * [Demo Server](#Demo-Server)
	   * [Tosca images](#Tosca-images)
	     * [Building images](#Building-images)
		 * [Using pre built images](#Using-pre-built-images)
		 * [Deploying images](#Deploying-images)
   * [Building Tosca Model Csars](#Building-Tosca-Model-Csars)
   * [Deployment Steps](#Deployment-Steps)
     * [Docker container based testing](#Docker-container-based-testing)
   * [Post Deployment Verification Steps](#Post-Deployment-Verification-Steps)
   * [To build gintelclient images](#To-build-gintelclient-images)
<!--te-->

## Introduction

  
  
## Pre Deployment Steps

- **Tickbonap Server**
    ------------
	This server is required for deploying the tickclamp model. 

	 - Create AWS VM in the Ohio region with name as follows use the following specifications and SSH it using putty by using cciPrivateKey:
    
	    ```sh
	    VM Name: Tickbonap Server 
        Image: ubuntu-18.04
        Instance Type: t2.large
        KeyPair : cciPublicKey
        Disk: 50GB
	    Security group: launch-wizard-19
	    ```
	
	 - Login into Tickbonap Server and perform steps as follows:
	
	    - Setup kubernetes
	   
	     ```sh
	     $ cd /home/ubuntu
         $ curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.9/bin/linux/amd64/kubectl
         $ sudo chmod +x ./kubectl
         $ sudo mv ./kubectl /usr/local/bin/kubectl
         $ grep -E --color 'vmx|svm' /proc/cpuinfo
	     ```
	  
	    - Copy cciPrivateKey into $HOME/.ssh
	  
	     ```sh
	     cp cciPrivateKey $HOME/.ssh
	     ```
	
    	- Run the following commands to setup k3sup:
	  
	     ```sh
	     $ sudo apt update
         $ curl -sLS https://get.k3sup.dev | sh
         $ sudo install k3sup /usr/local/bin/
         $ sudo apt-get install socat
         $ sudo apt install jq
  	     $ k3sup install --ip {PRIVATE_IP_ADDR_OF_TICKBONAP_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --context tick
  	     $ sudo mkdir ~/.kube 
         $ sudo cp /home/ubuntu/kubeconfig .kube/config
         $ sudo chmod 777 .kube/config
		 $ k3sup install --host {PRIVATE_IP_ADDR_OF_TICKBONAP_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --local-path ~/.kube/config --merge --context tick
	     ```
	  
	    - Run the following commands to install python,jq, and AWS CLI:
      
         ```sh
	     $ sudo apt-get update
         $ sudo apt-get install -y python
         $ sudo apt-get install -y python3-dev python3-pip
         $ sudo pip3 install --upgrade pip
         $ sudo pip3 install simplejson
         $ sudo apt-get install -y jq
         $ sudo apt install -y awscli
         $ sudo apt install -y python-pip
         $ pip2 install simplejson
         ```	
	  
        - Copy cciPrivateKey:
	
         ```sh
	     $ cd /home/ubuntu
         $ sudo mkdir onap-oom-integ
         $ sudo mkdir onap-oom-integ/cci
         $ sudo chmod -R 777 onap-oom-integ
         $ cp cciPrivateKey onap-oom-integ/cci
         ```	  
    
     -  Run the following commands:
	
	     ```sh
	     $ sudo apt update
         $ sudo apt install socat
		 $ sudo mkdir -p /etc/rancher/k3s
         $ sudo chmod -R 777 /etc/rancher/k3s
    
	     # Create a file named registries.yaml on this (/etc/rancher/k3s/) location and add the following content to it.
          mirrors:
            "172.31.27.186:5000":
               endpoint:
                 - "http://172.31.27.186:5000"
				 
	    $ sudo systemctl daemon-reload && sudo systemctl restart k3s
	    ```
		 
		**IMPORTANT NOTE: Above YAML must be in a valid format and proper indentation must be used.**
		
          Use following link to verify correctness of YAML:

		  ```sh
		  https://jsonformatter.org/yaml-validator
		  ```
		
     - Login into Tickbonap Server and run the following commands to check clustering setup:
	
	   - Verify 'tick' contexts are setup:  
		
		 ```sh
		 $ kubectl config get-contexts
		 
		 ubuntu@ip-172-31-18-15:~$ kubectl config get-contexts
		 CURRENT   NAME   CLUSTER   AUTHINFO   NAMESPACE
		 *         tick   tick      tick
		 ```
		  
	   - Run the following command to get all pods:
		
		 ```sh
		 $ kubectl get pods --all-namespaces
		 
		 ubuntu@ip-172-31-18-15:~$ kubectl get pods --all-namespaces
		 NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
		 kube-system   local-path-provisioner-64d457c485-9rt7f   1/1     Running     0          4m22s
		 kube-system   metrics-server-7b4f8b595-t4ffw            1/1     Running     0          4m22s
		 kube-system   helm-install-traefik-9w6sx                0/1     Completed   0          4m22s
		 kube-system   svclb-traefik-vd27f                       2/2     Running     0          4m8s
		 kube-system   coredns-5d69dc75db-sjf4c                  1/1     Running     0          4m22s
		 kube-system   traefik-5dd496474-4mxtd                   1/1     Running     0          4m8s
		 ```
		  
- **Creating Environment for Docker container based testing**
    -------------------------------------------------------

  - **DMaaP Server**
      ------------
      
    - Create AWS VM in Ohio region with following specifications and SSH it using putty by using cciPrivateKey:
    
      ```sh
	  Name: DMaaP Server
      Image: ubuntu-18.04
      Instance Type: t2.large
      Storage: 80GB
      KeyPair: cciPublicKey
	  Security group: launch-wizard-19
      ```
	  
	  Note: cciPrivateKey is the authentication key to login/ssh into AWS (which should be available with you locally).
	  
    - Setup Docker on DMaaP Server:
	
      ```sh
      $ sudo apt update
      $ sudo apt install docker.io
      $ sudo apt install docker-compose
	  
	  # Create a file named daemon.json in /etc/docker and add the following content to it.
           { "insecure-registries":["172.31.27.186:5000"] }
		
      $ sudo systemctl stop docker.socket 
      $ sudo systemctl start docker
      $ sudo chmod 777 /var/run/docker.sock
      ```
	  
	  Note: 172.31.27.186 is the private IP address of CCI_REPO VM.
	  
      Make sure Docker is installed properly by running the following command:
	  
      ```sh
      $ docker ps 
	  CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
	  $
      ```	 
	  
    - Clone the messageservice folder:
	
      ```sh
      $ cd ~/
      $ mkdir ~/local-dmaap
	  $ cd local-dmaap
      $ git clone https://gerrit.onap.org/r/dmaap/messagerouter/messageservice --branch honolulu
      ```
	
	  Replace the Docker image in docker-compose.yml (located in /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose)
	
      Image to be replaced:
	  
	  ```sh
	  image: nexus3.onap.org:10001/onap/dmaap/dmaap-mr:latest
	  ```
	  
	  New image:
	  
      ```sh          
      image: {IP_ADDR_OF_CCI_REPO}:5000/dmaap:localadapt_0.3
      ```
	
	- Verify that CCI_REPO VM on Ohio region is in running state. If it is not running then go to AWS and start it.
	
    - Start DMaaP Service:
	
      ```sh
      $ cd /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose
      $ docker-compose up -d
      ```
	  
    - Verify DMaaP Service is properly deployed:
  
	  Run the following command and verify that all containers are up.
	
	  ```sh
	  ubuntu@message_router:~/local-dmaap/messageservice/target/classes/docker-compose$ docker ps -a
	  CONTAINER ID   IMAGE                                              COMMAND                  CREATED         STATUS         PORTS                                                           NAMES
	  a234f9f984dd   dmaap:localadapt                                   "sh startup.sh"          6 seconds ago   Up 5 seconds   0.0.0.0:3904-3906->3904-3906/tcp, :::3904-3906->3904-3906/tcp   dockercompose_dmaap_1  
	  8058f11e9f57   nexus3.onap.org:10001/onap/dmaap/kafka111:1.0.4    "/etc/confluent/dock…"   7 seconds ago   Up 6 seconds   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp, 9093/tcp             dockercompose_kafka_1
	  a93fcf78bcb9   nexus3.onap.org:10001/onap/dmaap/zookeeper:6.0.3   "/etc/confluent/dock…"   9 seconds ago   Up 6 seconds   2888/tcp, 0.0.0.0:2181->2181/tcp, :::2181->2181/tcp, 3888/tcp   dockercompose_zookeeper_1
	  ```
	
	  Also, run the following command.
	
      ```sh
	  $ curl -X GET "http://{IP_ADDR_OF_DMAAP_SERVER}:3904/topics"
      ```
	  
	  Note : {IP_ADDR_OF_DMAAP_SERVER} is the public IP address of 'DMaaP Server'.
	  
      The above command return output as follows:
	  
      ```sh	  
	  {"topics": []}
	  ```

  - **Demo Server**
      -----------
      
    - Create AWS VM in Ohio region with following specifications and SSH it using putty by using cciPrivateKey:
    
      ```sh
      Name: Demo Server 	  
      Image: ubuntu-18.04
      Instance Type: t2.large
      Storage: 80GB
      KeyPair: cciPublicKey
	  Security group: launch-wizard-19
      ```
	 
	- Clone puccini: 
  
      ```sh
      $ git clone https://github.com/customercaresolutions/puccini
      ```
    
    - Setup Docker on Demo Server:
	
      ```sh
      $ sudo apt update
      $ sudo apt install -y docker.io
      $ sudo apt install -y docker-compose
	  
	  # Create a file named daemon.json in /etc/docker and add the following content to it.
         { "insecure-registries":["172.31.27.186:5000"] }
      
	  $ sudo systemctl stop docker.socket 
      $ sudo systemctl start docker
      $ sudo chmod 777 /var/run/docker.sock
      ```

      Make sure Docker is installed properly by running the following command:
		
      ```sh
      $ docker ps 
	  CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
	  $
      ```
	  
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
	  $ sudo kubectl apply -n onap -f /home/ubuntu/puccini/gawp/config/workflow-controller-configmap.yaml
	  $ curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.1.1/argo-linux-amd64.gz
	  $ gunzip argo-linux-amd64.gz
	  $ chmod +x argo-linux-amd64
	  $ sudo mv ./argo-linux-amd64 /usr/local/bin/argo
	  $ argo version
	  
	  # Use following commands on Demo Server VM to get external port of argo-server:
    	
      $ kubectl patch svc argo-server -n onap -p '{"spec": {"type": "LoadBalancer"}}'        
        service/argo-server patched

      $ kubectl get svc argo-server -n onap
        NAME          TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
        argo-server   LoadBalancer   10.103.17.134   <pending>     2746:31325/TCP   105m
	  ```
	  
	  Note: 31325 is the external port of argo-server.
	  
  - **Tosca images**
      ------------
	  
    - GIN consists of the following components:
	  
	  - TOSCA_SO - service orchestrator.
	  - TOSCA_COMPILER - puccini tosca compiler
	  - TOSCA_WORKFLOW - puccini-workflow microservice
	  - TOSCA_GAWP - argo workflow microservice
	  - TOSCA_POLICY - policy microservice
	  
	  GIN images can either be built from sources or their pre-built versions
	  can be used directly from CCI_REPO.
    
	  - **Building images**
	      ---------------
       
	    To build the images make sure puccini/docker-compose.yml looks as follows: 
		
	    ```sh
	    version: '3'
		services:
		  dgraphdb:
		    image: dgraph/standalone:latest
		    ports:
              - "8000:8000"
              - "8080:8080"
              - "9080:9080"
		    networks:
              - cciso-ntwk

		  orchestrator:
		    build:
              context: .
              dockerfile: Dockerfile.so.multistage
		    image: cci/tosca-so:latest
		    ports:
              - "10000:10000"
		    volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
		    networks:
              - cciso-ntwk
		    depends_on:
              - dgraphdb

		  compiler:
		    build:
              context: .
              dockerfile: Dockerfile.compiler.multistage
		    image: cci/tosca-compiler:latest
		    ports:
              - "10010:10010"
		    volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
		    networks:
              - cciso-ntwk
		    depends_on:
              - dgraphdb

		  workflow:
            build:
              context: .
              dockerfile: Dockerfile.workflow.multistage
            image: cci/tosca-workflow:latest
            ports:
              - "10020:10020"
            volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
            networks:
              - cciso-ntwk
            depends_on:
              - dgraphdb

		  policy:
            build:
              context: .
              dockerfile: Dockerfile.policy.multistage
            image: cci/tosca-policy:latest
            ports:
              - "10030:10030"
            volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
            networks:
              - cciso-ntwk
            depends_on:
              - dgraphdb
		  gawp:
            build:
              context: .
              dockerfile: Dockerfile.gawp.multistage
            image: cci/tosca-gawp:latest
            ports:
              - "10040:10040"
            volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
            networks:
              - cciso-ntwk
            depends_on:
              - dgraphdb
		# custom bridge network
		networks:
		  cciso-ntwk:
            driver: bridge  
	    ```	

      - **Using pre built images**
          ----------------------
		  
        To use pre-build images make sure puccini/docker-compose.yml looks as follows:
	    
	    ```sh
	    version: '3'
		services:
		  dgraphdb:
		    image: dgraph/standalone:latest
		    ports:
		      - "8000:8000"
		      - "8080:8080"
		      - "9080:9080"
		    networks:
		      - cciso-ntwk

		  orchestrator:
		    image: {IP_ADDR_OF_CCI_REPO}:5000/tosca-so:0.1
		    ports:
		      - "10000:10000"
		    volumes:
	          -  ./dvol/config:/opt/app/config
	          -  ./dvol/models:/opt/app/models
	          -  ./dvol/data:/opt/app/data
	          -  ./dvol/log:/opt/app/log
		    networks:
		      - cciso-ntwk
            depends_on:
              - dgraphdb

		  compiler:
		    image: {IP_ADDR_OF_CCI_REPO}:5000/tosca-compiler:0.1
		    ports:
              - "10010:10010"
		    volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
		    networks:
              - cciso-ntwk
		    depends_on:
              - dgraphdb

		  workflow:
            image: {IP_ADDR_OF_CCI_REPO}:5000/tosca-workflow:0.1
            ports:
              - "10020:10020"
            volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
            networks:
              - cciso-ntwk
            depends_on:
              - dgraphdb

		  policy:
            image: {IP_ADDR_OF_CCI_REPO}:5000/tosca-policy:0.1
            ports:
              - "10030:10030"
            volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
            networks:
              - cciso-ntwk
            depends_on:
              - dgraphdb
		  gawp:
            image: {IP_ADDR_OF_CCI_REPO}:5000/tosca-gawp:0.1
            ports:
              - "10040:10040"
            volumes:
              -  ./dvol/config:/opt/app/config
              -  ./dvol/models:/opt/app/models
              -  ./dvol/data:/opt/app/data
              -  ./dvol/log:/opt/app/log
            networks:
              - cciso-ntwk
            depends_on:
              - dgraphdb
		# custom bridge network
		networks:
		  cciso-ntwk:
            driver: bridge
        ```	  

      - **Deploying images**
	      ----------------
		  
	    - Modify ~/puccini/dvol/config/application.cfg as follows:
      
		  ```sh
		  [dgraph]
		  schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt

		  [remote]
		  remoteHost={IP_ADDR_OF_TICKBONAP_VM}
		  remotePort=22
		  remoteUser=ubuntu
		  remotePubKey=/opt/app/config/cciPrivateKey

		  [messageBus]
		  msgBusURL={IP_ADDR_OF_DMAAP_SERVER}:3904

		  [reposure]
		  reposureHost={IP_ADDR_OF_DEMO_SERVER} 
		  pushCsarToReposure=true

		  [argoWorkflow]
		  argoHost={IP_ADDR_OF_DEMO_SERVER} 
		  argoPort={EXTERNAL_PORT_OF_ARGO_SERVER}

		  tickServerIP=Private_IP_OF_TICKCLAMP_VM
		  
		  argoTemplateType=containerSet | DAG
		  ```

		  Note1 : {IP_ADDR_OF_DMAAP_SERVER} is the public IP address of 'DMaaP Server'(created in 'Pre Deployment Steps').

		  Note2 : Use 'kubectl get svc argo-server -n onap' command to get {EXTERNAL_PORT_OF_ARGO_SERVER}. Refer "Setup ARGO" section.
		   
        - Copy files as given follows:
	  
	      ```sh
	      $ cd ~/
	      $ cp cciPrivateKey puccini/dvol/config
		  $ cp /home/ubuntu/puccini/config/TOSCA-Dgraph-schema.txt /home/ubuntu/puccini/dvol/config/ 
	      ```

        - Build Docker images and start Docker containers:
		
          ```sh
          $ cd ~/puccini
          $ docker-compose up -d
          ```

        - Verify images are created:
		
          ```sh
          $ docker images -a
          ```
	
        - Verify Docker containers are deployed and all containers should be up.
   
          ```sh
          e.g:
          ubuntu@ip-172-31-24-235:~/puccini$ docker ps -a
          CONTAINER ID   IMAGE                       COMMAND              CREATED          STATUS          PORTS                                                                                                                             NAMES
          e0637ff71a78   cci/tosca-workflow:latest   "./tosca-workflow"   16 seconds ago   Up 14 seconds   0.0.0.0:10020->10020/tcp, :::10020->10020/tcp                                                                                     puccini_workflow_1
          2ed33c7803be   cci/tosca-so:latest         "./tosca-so"         16 seconds ago   Up 13 seconds   0.0.0.0:10000->10000/tcp, :::10000->10000/tcp                                                                                     puccini_orchestrator_1
          d6ba982d15e8   cci/tosca-policy:latest     "./tosca-policy"     16 seconds ago   Up 14 seconds   0.0.0.0:10030->10030/tcp, :::10030->10030/tcp                                                                                     puccini_policy_1
          68c6fa1fe966   cci/tosca-compiler:latest   "./tosca-compiler"   16 seconds ago   Up 11 seconds   0.0.0.0:10010->10010/tcp, :::10010->10010/tcp                                                                                     puccini_compiler_1
          344f5a9337e5   cci/tosca-gawp:latest       "./tosca-gawp"       16 seconds ago   Up 12 seconds   0.0.0.0:10040->10040/tcp, :::10040->10040/tcp                                                                                     puccini_gawp_1
          634cb15f41fe   dgraph/standalone:latest    "/run.sh"            17 seconds ago   Up 16 seconds   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp, 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:9080->9080/tcp, :::9080->9080/tcp   puccini_dgraphdb_1
		  ```
			  
## Building Tosca Model Csars

  **IMPORTANT NOTE: By default, GIN uses the 'argo-workflow' engine to deploy models. To use the 'puccini-workflow' engine, add workflow_engine_type  in the 'metadata' section of the main service template of a model.**
       
  **E.g : To use 'puccini-workflow' engine for tick deployment, add following in /home/ubuntu/tosca-models/cci/tickclamp/clamp_service.yaml**
  
  ```sh
  metadata:
    gwec-image: kuber_0.1
    argowfsteps: single-wfc
    workflow_engine_type : puccini-workflow
  ```
  
  Login into Demo Server and run the following commands:
  
  ```sh
  $ cd /home/ubuntu
  $ git clone https://github.com/customercaresolutions/tosca-models
  $ sudo chmod 777 -R tosca-models 
  ```
	
  Run following commands to build model csar.
	
  - TICKCLAMP:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/tickclamp
    $ ./build.sh
    ```  
   
    Check whether tickclamp csar is created in /home/ubuntu/tosca-models/cci directory.
    
## Deployment Steps
 
- **Docker container based testing**
    ------------------------------ 
   
  Login into Demo Server and fire the following commands to copy csars:
  
  ```sh
  $ cd ~/
  $ cd puccini/dvol/
  $ mkdir models
  $ cd ~/
  $ cd tosca-models/cci
  $ sudo chmod 777 -R /home/ubuntu/puccini/dvol/models
  $ cp tickclamp.csar /home/ubuntu/puccini/dvol/models
  ```

  - Use the following request to store the models in Dgraph:
	  
    For tickclamp model use following:
	  
    ```sh
	POST http://{IP_ADDR_OF_DEMO_SERVER}:10010/compiler/model/db/save
    {
      "url": "/opt/app/models/tickclamp.csar",
      "resolve": true,
      "coerce": false,
      "quirks": [
		  "data_types.string.permissive"
	  ],
      "output": "./tickclamp-dgraph-clout.json",
      "inputs": {
        "helm_version": "2.17.0",
        "k8scluster_name": "tick"
        },
      "inputsUrl": ""
    }
    ```

  - Create service instance with deployment:
	
	For tickclamp model use following:
	
	```sh			
	POST http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/createInstance
	{
      "name": "tickclamp",
      "output": "../../workdir/tickclamp-dgraph-clout.yaml",
      "inputs": {
          "helm_version": "2.17.0",
          "k8scluster_name": "tick"
      },
      "inputsUrl": "",
      "service": "zip:/opt/app/models/tickclamp.csar!/clamp_service.yaml",
      "generate-workflow": true,
      "execute-workflow": true,
      "list-steps-only": false,
      "execute-policy": true
    }
	```	
	
## Post Deployment Verification Steps

- When using 'argo-workflow', argo GUI can be used to verify and monitor deployment as follows:
  
  - Use following URL to open Argo GUI in local machine browser:
       
    ```sh
	https://{IP_ADDR_OF_DEMO_SERVER}:{EXTERNAL_PORT_OF_ARGO_SERVER}

    # e.g: https://3.142.145.230:31325
	```

    After opening argo GUI, Click on the 'workflow' with name starting with the 'instance name' name provided in POSTMAN.
	
    This will display workflow steps in Tree Format. If the model is deployed successfully, then it will show a 'right tick' symbol with green background.

- Use the following steps to verify tickclamp model is deployed successfully. 
  
  - Verify the tickclamp model:
  
	```sh
	$ kubectl get pods -n tick
	
	ubuntu@ip-172-31-18-15:~$ kubectl get pods -n tick
	NAME                                        READY   STATUS    RESTARTS   AGE
	tick-tel-telegraf-5b6c78f7c6-sj8dn          1/1     Running   0          14s
	tick-chron-chronograf-8f5966dbd-6fsgm       1/1     Running   0          13s
	tick-influx-influxdb-0                      1/1     Running   0          15s
	tick-kap-kapacitor-5cd49b877b-kz5j9         1/1     Running   0          14s
	tick-client-gintelclient-84c98c4478-dnsw2   1/1     Running   0          12s
	```

- Use following URL to open Chronograf GUI in local machine browser:
       
    ```sh
	http://{IP_ADDR_OF_TICKBONAP_VM}:30080

    # e.g: https://3.142.145.230:30080
	```
	
	- After opening Chronograf GUI, follow the below steps to login:
	
	  - Click on 'Get Start'.
	  - Replace Connection URL "http://localhost:8086" with "http://tick-influx-influxdb:8086" and also give connection name to Influxdb.
	  - Select the pre-created Dashboard e.g System, Docker.
	  - Replace Kapaciter URL "http://tick-influx-influxdb:9092/" with "http://tick-kap-kapacitor:9092/" and give name to Kapaciter.
	  - Then, click on 'Continue' and In the next step click on 'View all connection'.
	
	
	- After login successfully following tabs are showing on Chronograf GUI :
	  
	  - Status:
	  
	    It shows the status of all alerts, everyday events, etc.
		
	  - Explore:
	  
	    This tab helps to create a query, Dashboard as per requirements, and also helps in exploring the databases. 
	  
	  - Dashboard:
	  
	    This tab shows all the Dashboards which are pre-created or created while exploring.
		
	  - Altering:
	  
	    This tab, help to set alert's on different tag and fields.
		
	    - Manage Task:
		
		  Here, all alert's rule is created as per requirements. 
		  
	    - Alert History:
		
		  Here, All rules alert history display rule by rule.
		  
	  - Log Viewer:
	  
	  - InfuxDB Admin:
	  
	    This tab helps to create, manage databases and users. 
	  
	  - Configuration:
	  
	    This tab helps to manage all Kapaciters and their connection. 

## To build gintelclient images

- Create AWS VM in Ohio region with following specifications and SSH it using putty by using cciPrivateKey:
    
  ```sh
  Name: tick_Demo Server 	  
  Image: ubuntu-18.04
  Instance Type: t2.large
  Storage: 30GB
  KeyPair: cciPublicKey
  Security group: launch-wizard-19
  ```
	 
- Clone tel-client: 
  
  ```sh
  $ git clone https://github.com/customercaresolutions/tel-client
  ```
    
- Setup Docker on tick_Demo Server:
	
  ```sh
  $ sudo apt update
  $ sudo apt install -y docker.io
  $ sudo apt install -y docker-compose
	  
  # Create a file named daemon.json in /etc/docker and add the following content to it.
    { "insecure-registries":["172.31.27.186:5000"] }
      
  $ sudo systemctl stop docker.socket 
  $ sudo systemctl start docker
  $ sudo chmod 777 /var/run/docker.sock
  ```

  Make sure Docker is installed properly by running the following command:
		
  ```sh
  $ docker ps 
  CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
  $
  ```

- Use following command to build images:
  
  ```sh
  $ cd tel-client
  $ docker-compose up -d
  ```

- Verify Docker containers are deployed and all containers should be up
  
  ```sh
  $ docker ps -a
  
  ubuntu@ip-10-0-0-32:~$ docker ps -a
	CONTAINER ID   IMAGE                     COMMAND               CREATED       STATUS       PORTS                                         NAMES
	c1e469be51c9   cci/gintelclient:latest   "./tick-tel-client"   2 hours ago   Up 2 hours   0.0.0.0:8590->30085/tcp, :::8590->30085/tcp   telclient_tick-tel-client_1
  ```
