# GIN 
Table of contents
=================
<!--ts-->
   * [Introduction](#Introduction)
   * [Pre Deployment Steps](#Pre-Deployment-Steps)
     * [Creating Environment for Docker container based testing](#Creating-Environment-for-Docker-container-based-testing)
       * [DMaaP Server](#DMaaP-Server)
       * [Demo Server](#Demo-Server)
	   * [Tosca images](#Tosca-images)
	     * [Building images](#Building-images)
		 * [Using pre built images](#Using-pre-built-images)
		 * [Deploying images](#Deploying-images)
     * [Creating Environment for ONAP OOM testing](#Creating-Environment-for-ONAP-OOM-testing)
       * [OOM DEMO Server](#OOM-DEMO-Server)
     * [ORAN Servers](#ORAN-Servers)
	 * [Creating environment for OOM VM of HONOLULU release](#Creating-environment-for-OOM-VM-of-HONOLULU-release)
   * [Building Tosca Model Csars](#Building-Tosca-Model-Csars)
   * [Deployment Steps](#Deployment-Steps)
     * [Docker container based testing](#Docker-container-based-testing)
     * [ONAP OOM testing](#ONAP-OOM-testing)
	 * [ONAP OOM testing with HONOLULU release](#ONAP-OOM-testing-with-HONOLULU-release)
   * [Post Deployment Verification Steps](#Post-Deployment-Verification-Steps)
<!--te-->

## Introduction
  
  This page describes steps that need to be followed to create the necessary environment for deploying tosca models. It also describes steps for building csars for various models currently available.


## Pre Deployment Steps

There are two ways of deploying models for testing GIN functionality, one is Docker container and the other is ONAP OOM based.

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
      $ git clone https://gerrit.onap.org/r/dmaap/messagerouter/messageservice --branch frankfurt
      ```
	
	  Replace the Docker image in docker-compose.yml (located in /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose)
	
      Image to be replaced:
	  
	  ```sh
	  image:  nexus3.onap.org:10001/onap/dmaap/dmaap-mr:1.1.18
	  ```
	  
	  New image:
	  
      ```sh          
      image:  {IP_OF_CCI_REPO_ADDR}:5000/dmaap:localadapt_0.1
      ```
	
	- Verify that CCI_REPO VM on Ohio region is in running state. If it is not running then go to AWS and start it.
	
    - Start DMaaP Service:
      ```sh
      $ cd /home/ubuntu/local-dmaap/messageservice/src/main/resources/docker-compose
      $ docker-compose up -d
      ```
	  
    - Verify DMaaP Service is properly deployed:
  
	  Run the command given below and verify that all containers are up.
	
	  ```sh
	  ubuntu@message_router:~/local-dmaap/messageservice/target/classes/docker-compose$ docker ps -a
	  CONTAINER ID   IMAGE                                              COMMAND                  CREATED         STATUS         PORTS                                                           NAMES
	  a234f9f984dd   dmaap:localadapt                                   "sh startup.sh"          6 seconds ago   Up 5 seconds   0.0.0.0:3904-3906->3904-3906/tcp, :::3904-3906->3904-3906/tcp   dockercompose_dmaap_1  
	  8058f11e9f57   nexus3.onap.org:10001/onap/dmaap/kafka111:1.0.4    "/etc/confluent/dock…"   7 seconds ago   Up 6 seconds   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp, 9093/tcp             dockercompose_kafka_1
	  a93fcf78bcb9   nexus3.onap.org:10001/onap/dmaap/zookeeper:6.0.3   "/etc/confluent/dock…"   9 seconds ago   Up 6 seconds   2888/tcp, 0.0.0.0:2181->2181/tcp, :::2181->2181/tcp, 3888/tcp   dockercompose_zookeeper_1
	  ```
	
	  And run the following command 
	
      ```sh
	  $ curl -X GET "http://{IP_OF_DMAAP_SERVER_ADDR}:3904/topics"
      ```
	  
	  Note: {IP_OF_DMAAP_SERVER_ADDR} is the public IP address of 'DMaaP Server'
	  
      The above command should return output as follows:
	  
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
      ```
    
    - Setup Docker on Demo Server
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

      Make sure Docker is installed properly by running the following command:
		
      ```sh
      $ docker ps 
	  CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
	  $
      ```
	  
	  To deploy only sdwan and firewall model do some additional installation on Demo Server as follows:
	  
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
	  $ cd /home/ubuntu
      $ sudo mkdir onap-oom-integ
      $ sudo mkdir onap-oom-integ/cci
      $ sudo chmod -R 777 onap-oom-integ
      $ cp cciPrivateKey onap-oom-integ/cci
	  ```
	  
  - **Tosca images**
      ------------
      GIN consists of the following components:
	  
      - TOSCA_SO -  service orchestrator    
      - TOSCA_COMPILER - puccini tosca compiler
      - TOSCA_WORKFLOW - builtin workflow microservice
      - TOSCA_POLICY - policy microservice
      - TOSCA_GAWP - argo based workflow microservice
	  
	  These images can either be built from a scratch repository or a pre-build version of the images are used from CCI_REPO VM.
	  
	  Login into the Demo Server and perform steps as follows:
	
      - clone puccini:
  
        ```sh
        $ git clone https://github.com/customercaresolutions/puccini
        ```
    
	  - **Building images**
	      ---------------
        Make the following changes in puccini/docker-compose.yml of puccini
	    
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

      - **Using pre built images**
          ----------------------
        Make the following changes in puccini/docker-compose.yml of puccini
	    
	    ```sh
	    orchestrator:
            image: {IP_OF_CCI_REPO_ADDR}:5000/tosca-so:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    compiler:
		    image: {IP_OF_CCI_REPO_ADDR}:5000/tosca-compiler:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    workflow:
		    image: {IP_OF_CCI_REPO_ADDR}:5000/tosca-workflow:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    policy:
		    image: {IP_OF_CCI_REPO_ADDR}:5000/tosca-policy:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log

	    gawp:
		    image: {IP_OF_CCI_REPO_ADDR}:5000/tosca-gawp:0.1
		    volumes:
		      -  ../dvol/config:/opt/app/config
		      -  ../dvol/models:/opt/app/models
		      -  ../dvol/data:/opt/app/data
		      -  ../dvol/log:/opt/app/log
        ```	  

      - **Deploying images**
	      ---------
	    - Modify ~/puccini/dvol/config/application.cfg as follows:					
			
		      [remote]
		      remoteHost={IP_OF_SERVER_ADDR}
		      remotePort=22
		      remoteUser=ubuntu
		      remotePubKey=/opt/app/config/cciPrivateKey
		      msgBusURL={IP_OF_DMAAP_SERVER_ADDR}:3904
		      schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt
			
	    Note1: {IP_OF_SERVER_ADDR} should be set to {IP_OF_DEMO_SERVER_ADDR} (created in 'Pre Deployment Steps') for deploying sdwan, firewall or it should be set to {IP_OF_BONAP_SERVER_ADDR} (created in oran servers 'Pre Deployment Steps') for deploying oran models. 
			
        Note2: {IP_OF_DMAAP_SERVER_ADDR} is thr public IP address of 'DMaaP Server'(created in 'Pre Deployment Steps').  
	  
        - Copy files as given follows:
	  
	      ```sh
	      $ cd ~/
	      $ cp cciPrivateKey puccini/dvol/config
		  $ cd /home/ubuntu/puccini/config/
		  $ cp TOSCA-Dgraph-schema.txt /home/ubuntu/puccini/dvol/config/ 
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

- **Creating Environment for ONAP OOM testing**
    -----------------------------------------
    
  - **OOM DEMO Server**
      ---------------
      
    This server is used for testing in the ONAP OOM environment.
  
    - Create AWS VM in Ohio region with following specifications and SSH it using putty by using cciPrivateKey:
  
	  ```sh
	  Name: ONAP_OOM_DEMO
	  Image: ubuntu-18.04
      Instance Type: m5a.4xlarge
      Storage: 400GB
      KeyPair: cciPublicKey
      ```
  
    - Setup Docker:
  
      ```sh
	  $ sudo apt update
      $ sudo apt install apt-transport-https ca-certificates curl software-properties-common
      $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
      $ sudo apt update
      $ apt-cache policy docker-ce
      $ sudo apt-get install containerd.io docker-ce=5:18.09.5~3-0~ubuntu-bionic docker-ce-cli=5:18.09.5~3-0~ubuntu-bionic
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
	
    - Setup kubernetes:
  
      ```sh'
	  $ cd home/ubuntu
      $ curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.9/bin/linux/amd64/kubectl
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
      $ sudo minikube start --driver=none --kubernetes-version 1.15.9
      $ sudo mv /home/ubuntu/.kube /home/ubuntu/.minikube $HOME
      $ sudo chown -R $USER $HOME/.kube $HOME/.minikube
      $ kubectl get pods -n onap -o=wide
	  ```
	
    - Clone CCI ONAP OOM:
    
	  ```sh
	  $ cd ~/
      $ git clone https://github.com/customercaresolutions/onap-oom-integ.git -b frankfurt --recurse-submodules
      $ cd ~/onap-oom-integ/kubernetes
      $ git clone https://github.com/onap/testsuite-oom -b frankfurt robot
	  ```
	
    - Install Helm:
  
      ```sh
	  $ cd ~/
      $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
      $ sudo chmod 700 get_helm.sh
      $ ./get_helm.sh -v v2.16.6
      $ sudo cp -R ~/onap-oom-integ/kubernetes/helm/plugins/ ~/.helm
	  ```
	
    - Run the following commands for setting up the helm:
  
      ```sh
	  $ sudo helm init --stable-repo-url=https://charts.helm.sh/stable --client-only
      $ helm --tiller-namespace tiller version
      $ kubectl -n kube-system create serviceaccount tiller
      $ kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
      $ helm init --service-account tiller -i sapcc/tiller:v2.16.6
      $ sudo helm serve &
      $ sudo helm repo add local http://127.0.0.1:8879
      $ sudo helm repo list
      $ sudo apt install make
      $ sudo chmod -R 777 .helm
	  ```
	
    - Run the following commands to install python,jq, and AWS CLI:
  
	  ```sh
      $ sudo apt-get update
      $ sudo apt install python
      $ sudo apt-get -y install python-dev python-pip
      $ sudo pip install --upgrade pip
      $ sudo apt-get install jq
      $ sudo apt install awscli
	  $ sudo apt install python-pip
      $ pip2 install simplejson
	  ```
	  
    - Add public IP of Bonap Server VM in ~/onap-oom-integ/cci/application.cfg file:

      ```sh
      [remote]
      remoteHost={IP_OF_SERVER_ADDR}
      remotePort=22
      remoteUser=ubuntu
      remotePubKey=/opt/app/config/cciPrivateKey
	  ```	
	
	  Note: {IP_OF_SERVER_ADDR} should be set to {IP_OF_ONAP_OOM_DEMO} (created in 'Pre Deployment Steps') for deploying sdwan, firewall or it should be set to {IP_OF_BONAP_SERVER_ADDR} (created in oran servers 'Pre Deployment Steps') for deploying oran models.
	
    - Build helm charts:
  
      ```sh
	  $ cd /home/ubuntu/onap-oom-integ/kubernetes
      $ make SKIP_LINT=TRUE all; make SKIP_LINT=TRUE onap
      $ helm search onap -l
      $ sudo cp -R ~/onap-oom-integ/kubernetes/helm/plugins/ ~/.helm
      $ cd ../..
      $ sudo chmod -R 777 .helm
      $ sudo apt-get install socat
	  ```
	
	- Verify that CCI_REPO VM on Ohio region is in running state. If it is not running then go to AWS and start it.
	
    - Deploy ONAP:
    
	  ```sh
	  $ cd ~/onap-oom-integ/kubernetes
      $ helm deploy onap local/onap --namespace onap --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 900
	  ```
	
	  To deploy ONAP requires around 40-45 min. 
	  
    - To verify ONAP deployed successfully use the following command and all check all pods are in running state:

      ```sh
	  $ kubectl get pods -n onap
      ```	  
	
    - To access the portal using browser from your local machine, add public IP 'ONAP_OOM_DEMO' V in /etc/hosts file:
  
	  ```sh
	  {IP_OF_ONAP_OOM_DEMO} portal.api.simpledemo.onap.org    
      {IP_OF_ONAP_OOM_DEMO} vid.api.simpledemo.onap.org
      {IP_OF_ONAP_OOM_DEMO} sdc.api.simpledemo.onap.org
      {IP_OF_ONAP_OOM_DEMO} sdc.api.fe.simpledemo.onap.org
      {IP_OF_ONAP_OOM_DEMO} cli.api.simpledemo.onap.org
      {IP_OF_ONAP_OOM_DEMO} aai.api.sparky.simpledemo.onap.org
      {IP_OF_ONAP_OOM_DEMO} sdnc.api.simpledemo.onap.org
	  ```
	
    - Verify the following link should open in a browser to access the ONAP portal:
    
	  ```sh
	  https://portal.api.simpledemo.onap.org:30225/ONAPPORTAL/login.htm
	  ```
  
- **ORAN Servers**
    ------------
  These servers need to be created only if oran model(s) are to be deployed.
  
  - Create three AWS VMs in the Ohio region with names as follows:
    
	```sh
	VM1 Name: Bonap Server 
    VM2 Name: ric Server
    VM3 Name: nonrtric Server
    ```
	
	And use the following specifications and SSH it using putty by using cciPrivateKey:
	
	```sh
    Image: ubuntu-18.04
    Instance Type: t2.2xlarge
    KeyPair : cciPublicKey
    Disk: 80GB
	```
	
  - Login into Bonap Server and perform steps as follows:
	
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
  	  $ k3sup install --ip {PRIVATE_IP_OF_RIC_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --context ric
  	  $ sudo mkdir ~/.kube 
      $ sudo cp /home/ubuntu/kubeconfig .kube/config
      $ sudo chmod 777 .kube/config
  	   
      # Make sure the /home/ubuntu/kubeconfig file contains an entry of cluster and context for ric.
    
      $ k3sup install --host {PRIVATE_IP_OF_NONRTRIC_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --local-path ~/.kube/config --merge --context default
      $ k3sup install --host {PRIVATE_IP_OF_RIC_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --local-path ~/.kube/config --merge --context ric
	  ```
	  
	- Run the following commands to install python,jq, and AWS CLI:
      
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
    - Copy cciPrivateKey
	
      ```sh
	  $ cd /home/ubuntu
      $ sudo mkdir onap-oom-integ
      $ sudo mkdir onap-oom-integ/cci
      $ sudo chmod -R 777 onap-oom-integ
      $ cp cciPrivateKey onap-oom-integ/cci
      ```	  
    
  - Login into ric Server and nonrtric Server and run the following commands:
	
	```sh
	$ sudo apt update
    $ sudo apt install jq
    $ sudo apt install socat
    $ sudo chmod -R 777 /etc/rancher/k3s
    
	# Create a file named registries.yaml on this (/etc/rancher/k3s/) location and add the following content to it.
      mirrors:
       "172.31.27.186:5000":
          endpoint:
            - "http://172.31.27.186:5000"
	
	$ sudo systemctl daemon-reload && sudo systemctl restart k3s
	```
	
  - Login into Bonap Server and run the following commands to check clustering setup:
	
	- Verify 'ric' and 'default' contexts are setup:  
	  ```sh
	  $ kubectl config get-contexts
	  
	  ubuntu@ip-172-31-18-160:~$ kubectl config get-contexts
      CURRENT   NAME      CLUSTER   AUTHINFO   NAMESPACE
          default   default   default
      *         ric       ric       ric
	  ```
	  
	- Run the following command to get all pods:
	  ```sh
	  $ kubectl get pods --all-namespaces
	  
	  ubuntu@ip-172-31-18-160:~$ kubectl get pods --all-namespaces
      NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
      kube-system   local-path-provisioner-64d457c485-zn4pb   1/1     Running     0          25m
      kube-system   metrics-server-7b4f8b595-t9kcw            1/1     Running     0          25m
      kube-system   helm-install-traefik-xzpkg                0/1     Completed   0          25m
      kube-system   svclb-traefik-qxk6k                       2/2     Running     0          24m
      kube-system   coredns-5d69dc75db-pmc79                  1/1     Running     0          25m
      kube-system   traefik-5dd496474-bhwtb                   1/1     Running     0          24m
	  ```
	  
- **Creating environment for OOM VM of HONOLULU release**
    ---------------------------------------------------
  
  - **OOM DEMO Server**
      ---------------
	 
	- Create AWS VM in Ohio region with following specifications and SSH it using putty by using cciPrivateKey:
	  
	  ```sh
	  Name: ONAP_OOM_DEMO
	  Image: ubuntu-18.04
	  InstanceType: m5a.4xlarge
	  Storage: 100GB
	  KeyPair : cciPublicKey
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
	
    - Create oran setup:
      
	  - Puccini-workflow:
	    
		To create oran setup for Puccini-workflow use the ReadMe.md as follows:
		
		https://github.com/rajeshvkothari3003/oom/blob/master/GIN_README_2508.md#ORAN-Servers
	  
	  - Argo-workflow:
	    
		To create oran setup for Argo-workflow use the steps as follows:
	  
	    - Create two AWS VMs in the Ohio (us-east-2) region with names as follows:
		
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
		  ```
				   
	    - Login into ric Server and nonrtric Server and run the following commands:
		  
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
		  
    - Make the changes as per the requirement in the ~/onap-oom-integ/cci/application.cfg: 
	  
	  - For Puccini-workflow :
	    
		```sh
		[remote]
		remoteHost={IP_OF_SERVER_ADDR}
		remotePort=22
		remoteUser=ubuntu
		remotePubKey=/opt/app/config/cciPrivateKey
		workflowType=puccini-workflow
		```
		
		Note: {IP_OF_SERVER_ADDR} should be set to {IP_OF_ONAP_OOM_DEMO} (created in 'Pre Deployment Steps') for deploying sdwan, firewall or it should be set to {IP_OF_BONAP_SERVER_ADDR} (created in oran servers 'Pre Deployment Steps') for deploying oran models.
				
      - For Argo-workflow:

		```sh
		remoteHost={IP_OF_ONAP_OOM_DEMO}
		reposureHost={IP_OF_ONAP_OOM_DEMO}
		ricServerIP={IP_OF_RIC_VM_ADDR}
		nonrtricServerIP={IP_OF_NONRTRIC_VM_ADDR}
		workflowType=argo-workflow
        ```		
				
	  - For using containerSet based argo template set:
	    
		```sh
		argoTemplateType=containerSet
		```
				
	  - For using DAG based argo template set:
		
		```sh	
		argoTemplateType=DAG
		```
		
    - Install golang:
	  
	  ```sh
	  $ sudo curl -O https://storage.googleapis.com/golang/go1.17.linux-amd64.tar.gz
	  $ sudo tar -xvf go1.17.linux-amd64.tar.gz
	  $ sudo mv go /usr/local
	  
      # Add the below path in .profile file: 
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
	  $ sudo kubectl apply -n onap -f /home/ubuntu/onap-oom-integ/argo-config/workflow-controller-configmap.yaml 
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

	- Deploy ONAP:
		
	  ```sh
	  $ cd ~/onap-oom-integ/kubernetes
	  $ helm deploy onap local/onap --namespace onap --create-namespace --set     global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml --timeout 900s
      ```
	  
	  Note of ARGO-WORKFLOW: In case if ONAP deployed fails check logs in /home/ubuntu/.local/share/helm/plugins/deploy/cache/onap/logs
	
	- Copy updated CSARs to ~/onap-oom-integ/cci directory in ONAP_OOM_DEMO vm.
	  
## Building Tosca Model Csars
    
  Login into Demo Server or OOM VM and run the following commands.
	
  ```sh
  $ cd /home/ubuntu
  $ git clone https://github.com/customercaresolutions/tosca-models
  $ sudo chmod 777 -R tosca-models 
  ```
  
  Run following commands to build model csar.
	
  - SDWAN:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/sdwan
    $ ./build.sh
    ```  
  - FW:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/firewall
    $ ./build.sh
    ```
  - NONRTRIC:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/nonrtric
    $ ./build.sh
    ```
  - RIC:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/ric
    $ ./build.sh
    ```
  - QP:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/qp
    $ ./build.sh
    ```
  - QP-DRIVER:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/qp-driver
    $ ./build.sh
    ```
  - TS:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/ts
    $ ./build.sh
    ```
   
    Check whether all csar are created in /home/ubuntu/tosca-models/cci directory.
	
	To test through OOM Environment keep a copy of all csar on the local machine.
    
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
  $ cp sdwan.csar firewall.csar qp.csar qp-driver.csar ts.csar nonrtric.csar ric.csar /home/ubuntu/puccini/dvol/models
  ```

  - Use the following request to store the model in Dgraph:
	  
	```sh
	POST http://{IP_OF_DEMO_SERVER_ADDR}:10010/compiler/model/db/save
	{
	   "url":"/opt/app/models/<ModelName>.csar",
	   "output": "./<ModelName>-dgraph-clout.json",
	   "resolve":true,
	   "coerce": false,
	   "quirks": ["data_types.string.permissive"],
	   "inputs":"",
	   "inputsUrl": ""
	}
	``` 
	
	For the sdwan model, make the following changes in the above requests:
	
	```sh
	{
	   "inputs":"",
	   "url":"/opt/app/models/sdwan.csar",
	   "output": "./sdwan-dgraph-clout.json",
	}
    ```
	
	Note: Use a similar pattern for firewall, nonrtric, qp, qp-driver, ts model(means change only csar name).
	  
    For the ric model, make the following changes:
	  
	```sh
	{
      "inputs":{"helm_version":"2.17.0"},
      "url":"/opt/app/models/ric.csar",
      "output": "./ric-dgraph-clout.json",
    }
    ```	
	  
  - Create service Instance without deployment:
	
	For sdwan, firewall, nonrtric, ric, qp, qp-driver, ts:
	```sh			
	POST http://{IP_OF_DEMO_SERVER_ADDR}:10000/bonap/templates/createInstance
	{
		"name" : "<Instance_Name>",
		"output": "../../workdir/<ModelName>-dgraph-clout.yaml",
		"generate-workflow":true,
		"execute-workflow":true,
		"list-steps-only":true,
		"execute-policy":false
	}
	```
	  
    Use following models-specific additional fields:
	  
      **Firewall:**  
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml"
	  ```
	  
	  **Sdwan:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml"
	  ```
	  
	  **Ric:**
	  ```sh
	    "inputs":{"helm_version":"2.17.0"},
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/ric.csar!/ric.yaml"
	  ```	
	  
	  **Nonrtric:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/nonrtric.csar!/nonrtric.yaml"
	  ```
	  
	  **Qp:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/qp.csar!/qp.yaml"
	  ```
	 
	  **Qp-driver:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/qp-driver.csar!/qp-driver.yaml"
	  ```
	 
	  **Ts:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/ts.csar!/ts.yaml"
	  ```

  - Create service Instance with deployment:
	
	For sdwan, firewall, nonrtric, ric, qp, qp-driver, ts:
	
	```sh			
	POST http://{IP_OF_DEMO_SERVER_ADDR}:10000/bonap/templates/createInstance
	{
		"name" : "<Instance_Name>",
		"output": "../../workdir/<ModelName>-dgraph-clout.yaml",
		"generate-workflow":true,
		"execute-workflow":true,
		"list-steps-only":false,
		"execute-policy":true
	}
	```	
	  
    Use following models-specific additional fields:

      **Firewall:**  
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/firewall.csar!/firewall/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/firewall.csar!/firewall/firewall_service.yaml"
	  ```
	  
	  **Sdwan:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/models/sdwan.csar!/sdwan/inputs/aws.yaml",
	    "service":"zip:/opt/app/models/sdwan.csar!/sdwan/sdwan_service.yaml"
	  ```
	  
	  **Ric:**
	  ```sh
	    "inputs":{"helm_version":"2.17.0"},
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/ric.csar!/ric.yaml"
	  ```	
	  
	  **Nonrtric:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/nonrtric.csar!/nonrtric.yaml"
	  ```
	  
	  **Qp:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/qp.csar!/qp.yaml"
	  ```
	 
	  **Qp-driver:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/qp-driver.csar!/qp-driver.yaml"
	  ```
	 
	  **Ts:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"",
	    "service":"zip:/opt/app/models/ts.csar!/ts.yaml"
	  ```

  - To only list workflow steps of a model without executing/deploying them use the following:
	  
	```sh
    POST http://{IP_OF_DEMO_SERVER_ADDR}:10000/bonap/templates/<InstanceName>/workflows/deploy
	{
	   "list-steps-only": true,
	   "execute-policy": false
	}
	```		 

  - To Execute Workflow steps of a model which has already been saved in the database:
	   
	```sh	
    POST http://{IP_OF_DEMO_SERVER_ADDR}:10000/bonap/templates/<InstanceName>/workflows/deploy
	{
       "list-steps-only": false,
	   "execute-policy": true
	}
	```
	  
  - Execute Policy(This is valid only for the firewall model): 
	  
	```sh
	POST http://{IP_OF_DEMO_SERVER_ADDR}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
	```
	  
  - Stop Policy(This is valid only for the firewall model):
         
	```sh
	DELETE http://{IP_OF_DEMO_SERVER_ADDR}:10000/bonap/templates/<InstanceName>/policy/packet_volume_limiter
   	```
	  
  - Get Policies(This is valid only for the firewall model):
         
	```sh
	GET http://{IP_OF_DEMO_SERVER_ADDR}:10000/bonap/templates/<InstanceName>/policies
	```
	
	(TODO We can add the output of each command)
	
- **ONAP OOM testing**
    ----------------
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
	  
	  Note: Use the following headers in a POSTMAN request
	  
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
		
        NOTE: For new CCI models add a new service type in the service-subscription list of Create customer REST API
		
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
		
    - Update VID with the following REST requests using POSTMAN
	  
      Note: Use the following headers in the POSTMAN request
	  
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
      Select the Vendor and the Category as 'Network Service (Generic)' and give it a description then click on 'CREATE'.
      In the 'Software Product Details' box click on the warning as 'Missing' and select 'Licensing Version',
      'License Agreement' and 'Feature Groups'.
      Goto 'Overview'. In the 'Software Product Attachments' box click on 'SELECT File' and upload nonrtric/ric/qp/qp-driver/ts based on your requirement.
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
      Select a service and click Deploy.
      Complete the fields indicated by the red star and click Confirm.
      Wait for few minutes and it will return a success message.
      A service object is created in Puccini-SO.
      Click Close 
      ```
	  
    - Instantiate a VNF
		
      ```sh
	  Click on “Add node instance” and select the VNF available.
      Complete the fields indicated by the red star and click Confirm.
      Wait for 7-8 minutes and a success message will display.
      ```
  
- **ONAP OOM testing with HONOLULU release**

  - Use the following request to store the model in Dgraph:
    
	```sh
	POST http://{IP_OF_ONAP_OOM_DEMO_VM_ADDR}:30294/compiler/model/db/save
	{
	   "url":"/opt/app/config/<ModelName>.csar",
	   "output": "./<ModelName>-dgraph-clout.json",
	   "resolve":true,
	   "coerce":false,
	   "quirks": ["data_types.string.permissive"],
	   "inputs":"",
	   "inputsUrl": ""

	}
	```
	
	For the sdwan model, make the following changes in the above requests:
	
	```sh
	{
	   "inputs":"",
	   "url":"/opt/app/models/sdwan.csar",
	   "output": "./sdwan-dgraph-clout.json",
	}
    ```
	
	Note: Use a similar pattern for firewall, nonrtric, qp, qp-driver, ts model(means change only csar name).
	  
    For the ric model, make the following changes:
	  
	```sh
	{
      "inputs":{"helm_version":"2.17.0"},
      "url":"/opt/app/models/ric.csar",
      "output": "./ric-dgraph-clout.json",
    }
    ```
	
  - Create service Instance with deployment:
	
	For sdwan, firewall, nonrtric, ric, qp, qp-driver, ts:
	
	```sh			
	POST http://{IP_OF_ONAP_OOM_DEMO_VM_ADDR}:30280/bonap/templates/createInstance
	{
	   "name":"<Instance_Name>",
	   "output":"./<ModelName>.json",
	   "list-steps-only":false,
	   "generate-workflow":false,
	   "execute-workflow":false,
	   "execute-policy":false
	}
	```	
	  
    Use following models-specific additional fields:

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
  
    Use below API for all the models only replace the instance name which we used in the create instance step:
    
	```sh
	http://{IP_OF_ONAP_OOM_DEMO_VM_ADDR}:30280/bonap/templates/<Instance_Name>/workflows/deploy
		{
			"list-steps-only": false,
			"execute-policy": false
		}
	```
  
## Post Deployment Verification Steps 
 
  Use the following steps to verify models are deployed successfully. 
  
- Verify the sdwan model:  
 
  - Verify {service_instance_name}_SDWAN_Site_A and {service_instance_name}_SDWAN_Site_B VMs should be created on AWS N.California region.
  - SSH SDWAN_Site_A VM and run the following command:
    
	```sh
	$ ifconfig -a
	```
    Ping WAN Public IP, LAN Private IP(vvp1), and VxLAN IP(vpp2) of SDWAN_Site_B.
	
  - SSH SDWAN_Site_B VM and run the following command:
    
	```sh
	$ ifconfig -a
	```
	Ping WAN Public IP, LAN Private IP(vvp1), and VxLAN IP(vvp2) of SDWAN_Site_A.
	
- Verify firewall model:

  - Verify {service_instance_name}_firewall, {service_instance_name}_packet_genrator and {service_instance_name}_packet_sink VMs should be created on AWS N.Virginia region.

- Verify nonrtric model:
	
  - Verify that all pods are running using the following command on Bonap Server: 
    ```sh
	$ kubectl get pods -n nonrtric
	
	ubuntu@ip-172-31-47-62:~$ kubectl get pods -n nonrtric
	NAME                                       READY   STATUS    RESTARTS   AGE
	db-5d6d996454-2r6js                        1/1     Running   0          4m25s
	enrichmentservice-5fd94b6d95-sx9gx         1/1     Running   0          4m25s
	policymanagementservice-78f6b4549f-8skq2   1/1     Running   0          4m25s
	rappcatalogueservice-64495fcc8f-d77m7      1/1     Running   0          4m25s
	a1-sim-std-0                               1/1     Running   0          4m25s
	controlpanel-fbf9d64b6-npcxp               1/1     Running   0          4m25s
	a1-sim-osc-0                               1/1     Running   0          4m25s
	a1-sim-std-1                               1/1     Running   0          2m54s
	a1-sim-osc-1                               1/1     Running   0          2m50s
	a1controller-cb6d7f6b8-m4qcn               1/1     Running   0          4m25s
	```     
	
- Verify ric model:

  - Verify all pods are running using the following commands:
	```sh		
	$ kubectl get pods -n ricplt
	$ kubectl get pods -n ricinfra
	$ kubectl get pods -n ricxapp 

	ubuntu@ip-172-31-47-62:~$ kubectl get pods -n ricplt
	NAME                                                        READY   STATUS    RESTARTS   AGE
	statefulset-ricplt-dbaas-server-0                           1/1     Running   0          4m27s
	deployment-ricplt-xapp-onboarder-f564f96dd-tn9kg            2/2     Running   0          4m26s
	deployment-ricplt-jaegeradapter-5444d6668b-4gkk7            1/1     Running   0          4m19s
	deployment-ricplt-vespamgr-54d75fc6d6-9ljs4                 1/1     Running   0          4m20s
	deployment-ricplt-alarmmanager-5f656dd7f8-knj9s             1/1     Running   0          4m17s
	deployment-ricplt-submgr-5499794897-8rj9v                   1/1     Running   0          4m21s
	deployment-ricplt-e2mgr-7984fcdcb5-mlfh6                    1/1     Running   0          4m24s
	deployment-ricplt-o1mediator-7b4c8547bc-82kb8               1/1     Running   0          4m18s
	deployment-ricplt-a1mediator-68f8677df4-cvck9               1/1     Running   0          4m22s
	r4-infrastructure-prometheus-server-dfd5c6cbb-wrpp2         1/1     Running   0          4m28s
	r4-infrastructure-kong-b7cdbc9dd-g9qlc                      2/2     Running   1          4m28s
	r4-infrastructure-prometheus-alertmanager-98b79ccf7-pvfql   2/2     Running   0          4m28s
	deployment-ricplt-appmgr-5b94d9f97-mr7ld                    1/1     Running   0          2m16s
	deployment-ricplt-rtmgr-768655fc98-q6x28                    1/1     Running   2          4m25s
	deployment-ricplt-e2term-alpha-6c85bcf675-n6ckf             1/1     Running   0          4m23s
	
	ubuntu@ip-172-31-47-62:~$ kubectl get pods -n ricinfra
	NAME                                         READY   STATUS      RESTARTS   AGE
	tiller-secret-generator-4r45b                0/1     Completed   0          4m36s
	deployment-tiller-ricxapp-797659c9bb-b4kdz   1/1     Running     0          4m36s
	
	ubuntu@ip-172-31-47-62:~$ kubectl get pods -n ricxapp
	No resources found.
	```		

- Verify qp model:

  - Login 'Bonap Server' and run the following commands:
    ```sh
    $ cat /tmp/xapp.log
    
	# To check qp models deploy successfully, verify the following messages in /tmp/xapp.log.
      {"instances":null,"name":"qp","status":"deployed","version":"1.0"}
    ```	  

- Verify qp-driver model:

  - Login 'Bonap Server' and run the following commands:
    ```sh
    $ cat /tmp/xapp.log
    
	# To check qp-driver models deploy successfully, verify the following messages in /tmp/xapp.log.
      {"instances":null,"name":"qp-driver","status":"deployed","version":"1.0"}
    ``` 

- Verify ts model:

  - Login 'Bonap Server' and run the following commands:
    ```sh
    $ cat /tmp/xapp.log
    
	# To check ts models deploy successfully, verify the following messages in /tmp/xapp.log.
      {"instances":”null,"name":"trafficxapp","status":"deployed","version":"1.0"}
    ```    	  		   
