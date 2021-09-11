# Int_Honolulul

Table of contents
=================
<!--ts-->
   * [Introduction](#Introduction)
   * [Creating an environment for OOM VM of HONOLULU release](#Creating-an-environment-for-OOM-VM-of-HONOLULU-release)
   * [Testing of tosca models in HONOLULU release](#Testing-of-tosca-models-in-HONOLULU-release)
   * [Post Deployment Verification Steps](#Post-Deployment-Verification-Steps)
<!--te-->
## Introduction
  
  This page describes steps that need to be followed to create the necessary environment for deploying tosca models using built-in workflow or argo workflow. It also describes steps for building csars for various models currently available.
	
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
	  
	 Create oran setup when need to deploy oran models otherwise no need to set up them for sdwan and firewall model.
	  
	  GIN can deploy the tosca model using two ways.
	  
      - Build-in(puccini) workflow:
	     
		To create oran setup for Build-in(puccini) workflow use the README.md as follows:
		
		```sh
		https://github.com/rajeshvkothari3003/oom/blob/master/GIN_README_2508.md#ORAN-Servers
		```
	  
	  - Argo-workflow:
	    
		To create oran setup for Argo-workflow uses the steps as follows:
	  
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
		  
		  # Use the validate YAML format while adding the above content in registries.yaml. 
		  ```
		  
    - Make the changes as per the requirement in the ~/onap-oom-integ/cci/application.cfg: 
	  
	  - For Build-in(puccini) workflow:
	    
		```sh
		[remote]
		remoteHost={IP_OF_SERVER_ADDR}
		remotePort=22
		remoteUser=ubuntu
		remotePubKey=/opt/app/config/cciPrivateKey
		workflowType=puccini-workflow
		```
		
		Note: {IP_OF_SERVER_ADDR} should be set to {IP_OF_ONAP_OOM_DEMO_ADDR} (created in 'Pre Deployment Steps') for deploying sdwan, firewall or it should be set to {IP_OF_BONAP_SERVER_ADDR} (created in oran servers 'Pre Deployment Steps') for deploying oran models.
				
      - For Argo-workflow:

		```sh
		remoteHost={IP_OF_ONAP_OOM_DEMO_ADDR}
		reposureHost={IP_OF_ONAP_OOM_DEMO_ADDR}
		reposureHost={IP_OF_ONAP_OOM_DEMO_ADDR}
		ricServerIP={IP_OF_RIC_ADDR}
		nonrtricServerIP={IP_OF_NONRTRIC_ADDR}
		workflowType=argo-workflow
        ```		
		
		Note: To deploy a firewall, sdwan models add only {IP_OF_ONAP_OOM_DEMO_ADDR} and oran models add all IP.
		
		In an Argo workflow, there is two ways/method for executing argo template.
		
        - containerSet : Add one line description
				
	      - For using containerSet based argo template set:
	    
		    ```sh
		    argoTemplateType=containerSet
		    ```
			
        - DAG : Add one line description
				
	      - For using DAG-based argo template set:
		
		    ```sh	
		    argoTemplateType=DAG
		    ```
		
    - Install golang:
	  
	  ```sh
	  $ sudo curl -O https://storage.googleapis.com/golang/go1.17.linux-amd64.tar.gz
	  $ sudo tar -xvf go1.17.linux-amd64.tar.gz
	  $ sudo mv go /usr/local
	  
      # Add the below paths in .profile file: 
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
	  
	  # For containerSet use below command:
	  $ sudo kubectl apply -n onap -f /home/ubuntu/onap-oom-integ/argo-config/workflow-controller-configmap.yaml 
	  
	  # For DAG use the below command:
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
	  
	  To deploy ONAP requires around 25-30 min.
	  
	  Note for ARGO-WORKFLOW: In case if ONAP deployed fails check logs in /home/ubuntu/.local/share/helm/plugins/deploy/cache/onap/logs
	  
	- To verify ONAP deployed successfully use the following command and all check all pods are in running state:

      ```sh
	  $ kubectl get pods -n onap
	  ```
	
	- To build the csars follow the README.md as follows:
	
      ```sh
	  https://github.com/rajeshvkothari3003/oom/blob/master/GIN_README_2508.md#Building-Tosca-Model-Csars
	  ```
	
	- Copy updated csars to ~/onap-oom-integ/cci directory in ONAP_OOM_DEMO VM.

## Testing of tosca models in HONOLULU release

  Send requests to tosca pods using postman.

- Use the following request to store the model in Dgraph:
    
  ```sh
  POST http://{IP_OF_ONAP_OOM_DEMO_ADDR}:30294/compiler/model/db/save
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
	
- Create service Instance:
	
  For sdwan, firewall, nonrtric, ric, qp, qp-driver, ts:
	
  ```sh			
  POST http://{IP_OF_ONAP_OOM_DEMO_ADDR}:30280/bonap/templates/createInstance
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
  http://{IP_OF_ONAP_OOM_DEMO_ADDR}:30280/bonap/templates/<Instance_Name>/workflows/deploy
  {
	 "list-steps-only": false,
	 "execute-policy": false
  }
  ```
  
  Note: While testing if nonrtric get failed then check that whether the ks3 is installed properly or not by running the command on ric and nonrtric VM as follows:
  ```sh
  ournalctl -xe
  ```
  Also, check the registries.yaml whether it contains the validated YAML format or not. if not then validate that content and run the below command:
  ```sh
  sudo systemctl restart k3s
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
	
  - Verify that all pods are running using the following command on a nonrtric Server: 
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

  - Verify all pods are running using the following commands on ric Server:
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

  - Login 'ONAP_OOM_DEMO' and run the following commands:
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
	  f1bc78609f02        449444000066                                       "/var/run/argo/argoe…"    About an hour ago   Exited (0) About an hour ago    k8s_main_qp1pq8kc_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

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

  - Login 'ONAP_OOM_DEMO' and run the following commands:
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
	  u1ft76609r05        689546000088                                       "/var/run/argo/argoe…"    About an hour ago   Exited (0) About an hour ago    k8s_main_qp-deriver4rq2ws_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

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

  - Login 'ONAP_OOM_DEMO' and run the following commands:
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
	  b1bd76609t06        689546000088                                       "/var/run/argo/argoe…"    About an two ago   Exited (0) About an hour ago    k8s_main_ts9dt4xz_onap_7a7109ed-af0a-4b4b-ac86-f5cbc36814d7_0

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
