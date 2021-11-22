# GIN 
Table of contents
=================
<!--ts-->
   * [Introduction](#Introduction)
   * [Pre Deployment Steps](#Pre-Deployment-Steps)
     * [RIC Servers](#RIC-Servers)
     * [Creating Environment for GIN based testing](#Creating-Environment-for-GIN-based-testing)
       * [GIN Server](#GIN-Server)
   * [Building Tosca Model Csars](#Building-Tosca-Model-Csars)
   * [Deployment Steps](#Deployment-Steps)
     * [GIN based testing](#GIN-based-testing)
   * [Post Deployment Verification Steps](#Post-Deployment-Verification-Steps)
<!--te-->

## Introduction

  This page describes steps that need to be followed to create the necessary environment for deploying tosca models using argo-workflow. It also describes steps for building csars for various models currently available.
  
## Pre Deployment Steps

There are two sub-sections within this section and they are not mandatory. Follow/complete only those sections which are relevant to the type of models/deployment.

[Ric Servers](#Ric-Servers) should be completed only if ric models are to be deployed.

[Creating Environment for GIN based testing](#Creating-Environment-for-GIN-based-testing) should be completed only if deployment is to be tested in GIN based environment. This is not required for GIN based deployment.

So, for example, to deploy SDWAN, ignore first and only perform steps given in second.

- **RIC Servers**
    --------------------------
	These servers are required for deploying RIC model.
	
	**IMPORTANT NOTE : ric server is required ONLY if ric model are to be deployed.**
	
	 - Create AWS VMs in the Ohio region with names as follows use the following specifications and SSH it using putty by using cciPrivateKey:
    
	   ```sh
       VM1 Name: ric Server
       Image: ubuntu-18.04
       Instance Type: t2.xlarge
       KeyPair : cciPublicKey
       Disk: 80GB
	   Security group: launch-wizard-19
	   vpcId: vpc-9be007f3
	   ```

     - Login into ric and run following commands:
	
	   ```sh
	   $ sudo apt update
       $ sudo apt install -y jq socat
	   $ sudo mkdir -p /etc/rancher/k3s
       $ sudo chmod -R 777 /etc/rancher/k3s
    
	   $ git clone https://github.com/customercaresolutions/gin-utils
	   $ sudo cp gin-utils/config/registries.yaml /etc/rancher/k3s/registries.yaml	 
	   ```
		 
- **Creating Environment for GIN based testing**
    -----------------------------------------------

  - **GIN Server**
      ---------------
      
    - Create AWS VM in Ohio region with following specifications and SSH it using putty by using cciPrivateKey:
    
      ```sh
	  Name: GIN Server
      Image: ubuntu-18.04
      Instance Type: t2.2xlarge
      Storage: 100GB
      KeyPair: cciPublicKey
	  Security group: launch-wizard-19
	  vpcId: vpc-9be007f3
      ```
	  
	  Note : cciPrivateKey is the authentication key to login/ssh into AWS (which should be available with you locally).
	  
    - Clone gin-utils:
	
	  ```sh
	  $ git clone https://github.com/customercaresolutions/gin-utils
	  ```
	
	- Setup k3s:
	
      ```sh
      $ sudo apt update
      $ curl -sfL https://get.k3s.io | sh -
      $ mkdir -p $HOME/.kube
      $ sudo chmod 777 /etc/rancher/k3s/k3s.yaml
      $ sudo kubectl config set-context --current --namespace=default
      $ sudo cp /etc/rancher/k3s/k3s.* $HOME/.kube/config
      $ sudo chown $(id -u):$(id -g) $HOME/.kube/config
	  
      $ kubectl get node
      $ kubectl get pods --all-namespaces
      $ sudo cp gin-utils/config/registries.yaml /etc/rancher/k3s/registries.yaml
	
      $ sudo systemctl daemon-reload && sudo systemctl restart k3s
      $ sudo chmod 777 /etc/rancher/k3s/k3s.yaml
      ```
	  
    - Make changes in ~/.kube/config file as follows:
	
      ```sh
	  $ vi ~/.kube/config 
	  
      server: https://{PRIVATE_IP_OF_GIN_VM}:6443
      ```
	
    - Setup helm:
	
      ```sh
      $ wget https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz
      $ tar xvfz helm-v3.5.2-linux-amd64.tar.gz
      $ sudo mv linux-amd64/helm /usr/local/bin/helm
      ```
	
	- Verify that CCI_REPO VM on Ohio region is in running state. If it is not running then go to AWS and start it.
	
	- Setup DMAAP:
	
	  ```sh
      $ kubectl create ns gin
	  
      $ helm install --kubeconfig=$HOME/.kube/config /home/ubuntu/gin-utils/helm-charts/zk-6.0.3.tar.gz -f /home/ubuntu/gin-utils/helm-charts/zk-values.yaml --namespace gin --generate-name
	  
      $ helm install --kubeconfig=$HOME/.kube/config /home/ubuntu/gin-utils/helm-charts/kafka-1.0.4.tar.gz -f /home/ubuntu/gin-utils/helm-charts/kafka-values.yaml --namespace gin --generate-name
	  
      $ helm install --kubeconfig=$HOME/.kube/config /home/ubuntu/gin-utils/helm-charts/dmaap-18.0.1.tar.gz -f /home/ubuntu/gin-utils/helm-charts/dmaap-values.yaml --namespace gin --generate-name
      ```
	
	- Setup GIN:
	
      ```sh
      $ git clone https://github.com/customercaresolutions/puccini
      ```
	  
	  - Setup config parameters in puccini/dvol/config/application.cfg
	  
        ```sh
        [dgraph]
        host=tosca-dgraph
        schemaFilePath=/opt/app/config/TOSCA-Dgraph-schema.txt

        [remote]
        remoteHost={IP_ADDR_OF_GIN_SERVER}
        remotePubKey=/opt/app/config/cciPrivateKey

        [messageBus]
        msgBusURL=dmaap:3904

        [reposure]
        reposureHost={IP_ADDR_OF_GIN_SERVER} 
        pushCsarToReposure=true

        [argoWorkflow]
        ricServerIP={PRIVATE_IP_ADDR_OF_RIC_VM}
        ginServerIP={PRIVATE_IP_OF_GIN_SERVER}

        argoTemplateType=containerSet | DAG
		argoServerNamespace=gin
        ```
		
	    Note : If ORAN servers have not been created, then keep ricServerIP, ginServerIP values as is. Otherwise add private IP of ricServer, ginServerIP(created in Pre Deployment Steps').
	  
	  - Copy following files:
	  
        ```sh
        $ cp cciPrivateKey puccini/dvol/config
        $ cp /home/ubuntu/puccini/config/TOSCA-Dgraph-schema.txt /home/ubuntu/puccini/dvol/config/ 
        ```
	  
      - Deploy gin through helm chart:
	  
	    ```sh
	    $  helm install --kubeconfig=$HOME/.kube/config /home/ubuntu/gin-utils/helm-charts/gin-0.3.tgz --namespace gin --generate-name
	    ```
	 
    - Setup reposure:
	
	  ```sh
	  $ chmod +x gin-utils/reposure/reposure
	  $ sudo cp gin-utils/reposure/reposure /usr/local/bin/reposure
	  $ reposure operator install --wait
	  $ reposure simple install --wait
	  $ reposure registry create default --provider=simple --wait -v
	  ```
	  
	- Setup Argo:
	
	  ```sh
	  $ sudo kubectl apply -n gin -f /home/ubuntu/puccini/gawp/config/workflow-controller-configmap.yaml
	  $ kubectl patch svc argo-server -n gin -p '{"spec": {"type": "LoadBalancer"}}'
	  $ kubectl get svc argo-server -n gin
	  
	  ubuntu@ip-172-31-18-127:~$ kubectl get svc argo-server -n gin
	  NAME          TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
	  argo-server   LoadBalancer   10.43.45.202   172.31.18.127   2746:31960/TCP   11s
	  ```
	  
	  Note : 31960 is the external port of argo-server.
	  
    - To verify that GIN is deployed successfully, use the following command and check that all pods are in running state:
	
      ```sh
      $ ubuntu@ip-172-31-18-127:~$ kubectl get pods -n gin
		NAME                                   READY   STATUS    RESTARTS   AGE
		zookeeper-85fbfbb49f-mr9kb             1/1     Running   0          8m53s
		kafka111-7746747c8d-4pbxg              1/1     Running   0          8m46s
		dmaap-5bddfd7f4b-g8skk                 1/1     Running   0          8m41s
		gin-tosca-dgraph-85f8f7c7c6-hg2td      2/2     Running   0          5m4s
		gin-tosca-gawp-56b7df545-mjf7m         2/2     Running   0          5m4s
		gin-tosca-policy-5c794c48cd-wgzcf      2/2     Running   0          5m4s
		gin-tosca-5d8c8f84ff-76nk7             2/2     Running   0          5m4s
		gin-tosca-workflow-65f6786c8c-fwv7k    2/2     Running   0          5m4s
		gin-tosca-compiler-596675bb84-g7d6j    2/2     Running   0          5m4s
		svclb-argo-server-ghdn6                1/1     Running   0          3m55s
		minio-74d9d98bbb-nnzdg                 1/1     Running   0          4m
		postgres-77dc5db9d4-l4g24              1/1     Running   0          3m59s
		workflow-controller-847654dd4d-m5xhn   1/1     Running   1          3m59s
		argo-server-67dc857958-nsxxt           1/1     Running   1          4m
	  ```
	  
	  Note : This step requires around 2-3 min to deploy GIN components.
			  
## Building Tosca Model Csars

  **IMPORTANT NOTE : By default GIN uses 'argo-workflow' engine to deploy models.**

  Login into GIN Server and run the following commands:
  
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
  - TICKCLAMP:
    ```sh
	$ cd /home/ubuntu/tosca-models/cci/tickclamp
    $ ./build.sh  
    ```

    Check whether all csar are created in /home/ubuntu/tosca-models/cci directory.
    
## Deployment Steps
 
- **GIN based testing**
    ---------------------- 
   
  Login into GIN Server and run the following commands to copy csars:
  
  ```sh
  $ cd ~/
  $ cd tosca-models/cci
  $ cp sdwan.csar firewall.csar qp.csar qp-driver.csar ts.csar nonrtric.csar ric.csar tickclamp.csar /home/ubuntu/puccini/dvol/config
  ```

  - Use the following request to store the models in Dgraph:
	  
	For sdwan, firewall, nonrtric, qp, qp-driver, ts models use following:
    
    ```sh
	POST http://{IP_ADDR_OF_GIN_SERVER}:30294/compiler/model/db/save
    {
	  "url": "/opt/app/config/{MODEL_NAME}.csar",
	  "resolve": true,
	  "coerce": false,
	  "quirks": [
			"data_types.string.permissive"
		],
	  "output": "./{MODEL_NAME}-dgraph-clout.json",
	  "inputs": "",
	  "inputsUrl": ""
	}
    ```
	  
    For ric model use following:
	  
    ```sh
	POST http://{IP_ADDR_OF_GIN_SERVER}:30294/compiler/model/db/save
    {
	  "url": "/opt/app/config/ric.csar",
	  "resolve": true,
	  "coerce": false,
	  "quirks": [
			"data_types.string.permissive"
		],
	  "output": "./ric-dgraph-clout.json",
	  "inputs": {
          "helm_version": "2.17.0"
       },
	  "inputsUrl": ""
	}
    ```
	
	For tickclamp model use following:
	
	```sh
	POST http://{IP_ADDR_OF_GIN_SERVER}:30294/compiler/model/db/save
	{
	  "url": "/opt/app/config/tickclamp.csar",
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
	
	For sdwan, firewall, nonrtric, ric, qp, qp-driver and ts:
	
	```sh			
	POST http://{IP_ADDR_OF_GIN_SERVER}:30280/bonap/templates/createInstance
	{
		"name" : "{INSTANCE_NAME}",
		"output": "../../workdir/{MODEL_NAME}-dgraph-clout.yaml",
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
	    "inputsUrl":"zip:/opt/app/config/firewall.csar!/firewall/inputs/aws.yaml",
	    "service":"zip:/opt/app/config/firewall.csar!/firewall/firewall_service.yaml"
	  ```
	  
	  **Sdwan:**
	  ```sh
	    "inputs":"",
	    "inputsUrl":"zip:/opt/app/config/sdwan.csar!/sdwan/inputs/aws.yaml",
	    "service":"zip:/opt/app/config/sdwan.csar!/sdwan/sdwan_service.yaml"
	  ```
	  
	  **Tickclamp:**
	  ```sh
	    "inputs":{"helm_version": "2.17.0", "k8scluster_name": "tick"},
        "inputsUrl": "",
        "service": "zip:/opt/app/config/tickclamp.csar!/clamp_service.yaml"
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

  - To Execute Workflow steps of a model which has already been saved in the database:
	   
	```sh	
    POST http://{IP_ADDR_OF_GIN_SERVER}:30280/bonap/templates/{INSTANCE_NAME}/workflows/deploy
	{
       "list-steps-only": false,
	   "execute-policy": true
	}
	```
	  
  - Execute Policy(This is valid only for the firewall model): 
	  
	```sh
	POST http://{IP_ADDR_OF_GIN_SERVER}:30280/bonap/templates/{INSTANCE_NAME}/policy/packet_volume_limiter
	```
	  
  - Stop Policy(This is valid only for the firewall model):
         
	```sh
	DELETE http://{IP_ADDR_OF_GIN_SERVER}:30280/bonap/templates/{INSTANCE_NAME}/policy/packet_volume_limiter
   	```
	  
  - Get Policies(This is valid only for the firewall model):
         
	```sh
	GET http://{IP_ADDR_OF_GIN_SERVER}:30280/bonap/templates/{INSTANCE_NAME}/policies
	```

## Post Deployment Verification Steps

- When using 'argo-workflow', argo GUI can be used to verify and monitor deployment as follows:
  
  - Use following URL to open Argo GUI in local machine browser:
       
    ```sh
	https://{IP_ADDR_OF_GIN_VM}:{EXTERNAL_PORT_OF_ARGO_SERVER}

    # e.g: https://3.142.145.230:31325
	```

    After opening argo GUI, Click on the 'workflow' with name starting with the 'instance' name provided in 'Create service instance with deployment' section.
	
    This will display workflow steps in Tree Format. If the model is deployed successfully, then it will show a 'right tick' symbol with green background.

- After, deploying tickclamp model use following URL to open Chronograf GUI in local machine browser:
       
    ```sh
	http://{IP_ADDR_OF_TICKBONAP_VM}:30080

    # e.g: http://23.124.125.320:30080
	```
	
	- After opening Chronograf GUI, follow the below steps to login:
	
	  - Click on 'Get Start'.
	  - Replace Connection URL "http://localhost:8086" with "http://tick-influx-influxdb:8086" and also give connection name to Influxdb.
	  - Select the pre-created Dashboard e.g System, Docker, etc.
	  - Replace Kapaciter URL "http://tick-influx-influxdb:9092/" with "http://tick-kap-kapacitor:9092/" and give name to Kapaciter.
	  - Then, click on 'Continue' and In the next step click on 'View all connection'.
		
- Use the following steps to verify sdwan, firewall, tickclamp, oran models are deployed successfully. 
  
  - Verify the sdwan model:
		
	  Verify {SERVICE_INSTANCE_NAME}_SDWAN_Site_A and {SERVICE_INSTANCE_NAME}_SDWAN_Site_B VMs should be created on AWS N.California region.

	  - SSH SDWAN_Site_A VM and run the following command:
			
		```sh
		$ ifconfig -a
			
		ubuntu@ip-172-19-254-33:~$ ifconfig -a
		ens5: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9001
			  inet 172.19.254.33  netmask 255.255.255.0  broadcast 0.0.0.0
			  inet6 fe80::4cf:94ff:fe39:30a7  prefixlen 64  scopeid 0x20<link>
			  ether 06:cf:94:39:30:a7  txqueuelen 1000  (Ethernet)
			  RX packets 139  bytes 25029 (25.0 KB)
			  RX errors 0  dropped 0  overruns 0  frame 0
			  TX packets 161  bytes 24640 (24.6 KB)
			  TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

		lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
			inet 127.0.0.1  netmask 255.0.0.0
			inet6 ::1  prefixlen 128  scopeid 0x10<host>
			loop  txqueuelen 1000  (Local Loopback)
			RX packets 254  bytes 21608 (21.6 KB)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 254  bytes 21608 (21.6 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

		vpp1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
			  inet 172.19.1.249  netmask 255.255.255.0  broadcast 0.0.0.0
			  inet6 fe80::476:2dff:fe3c:f8a9  prefixlen 64  scopeid 0x20<link>
			  ether 06:76:2d:3c:f8:a9  txqueuelen 1000  (Ethernet)
			  RX packets 3  bytes 126 (126.0 B)
			  RX errors 0  dropped 0  overruns 0  frame 0
			  TX packets 40  bytes 2852 (2.8 KB)
			  TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

		vpp2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1350
			  inet 10.100.0.18  netmask 255.255.255.254  broadcast 0.0.0.0
			  inet6 fe80::27ff:fefd:18  prefixlen 64  scopeid 0x20<link>
			  ether 02:00:27:fd:00:18  txqueuelen 1000  (Ethernet)
			  RX packets 38  bytes 3260 (3.2 KB)
			  RX errors 0  dropped 1  overruns 0  frame 0
			  TX packets 50  bytes 4164 (4.1 KB)
			  TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
		```
		
		Ping WAN Public IP, LAN Private IP(vpp1), and VxLAN IP(vpp2) of SDWAN_Site_B.
			
      - SSH SDWAN_Site_B VM and run the following command:
			
	    ```sh
	    $ ifconfig -a
			
		ubuntu@ip-172-14-254-13:~$ ifconfig -a
		ens5: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9001
			  inet 172.14.254.13  netmask 255.255.255.0  broadcast 0.0.0.0
			  inet6 fe80::43f:10ff:fedf:b2b3  prefixlen 64  scopeid 0x20<link>
			  ether 06:3f:10:df:b2:b3  txqueuelen 1000  (Ethernet)
			  RX packets 322  bytes 38221 (38.2 KB)
			  RX errors 0  dropped 0  overruns 0  frame 0
			  TX packets 325  bytes 37083 (37.0 KB)
			  TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

		lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
			inet 127.0.0.1  netmask 255.0.0.0
			inet6 ::1  prefixlen 128  scopeid 0x10<host>
			loop  txqueuelen 1000  (Local Loopback)
			RX packets 255  bytes 21720 (21.7 KB)
			RX errors 0  dropped 0  overruns 0  frame 0
			TX packets 255  bytes 21720 (21.7 KB)
			TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

		vpp1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
			  inet 172.14.1.152  netmask 255.255.255.0  broadcast 0.0.0.0
			  inet6 fe80::4a3:43ff:fe0a:33eb  prefixlen 64  scopeid 0x20<link>
			  ether 06:a3:43:0a:33:eb  txqueuelen 1000  (Ethernet)
			  RX packets 6  bytes 252 (252.0 B)
			  RX errors 0  dropped 0  overruns 0  frame 0
			  TX packets 63  bytes 4530 (4.5 KB)
			  TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

		vpp2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1350
			  inet 10.100.0.19  netmask 255.255.255.254  broadcast 0.0.0.0
			  inet6 fe80::27ff:fefd:19  prefixlen 64  scopeid 0x20<link>
			  ether 02:00:27:fd:00:19  txqueuelen 1000  (Ethernet)
			  RX packets 64  bytes 5380 (5.3 KB)
			  RX errors 0  dropped 1  overruns 0  frame 0
			  TX packets 83  bytes 6698 (6.6 KB)
			  TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
		```
			
		Ping WAN Public IP, LAN Private IP(vpp1), and VxLAN IP(vpp2) of SDWAN_Site_A.
		
  - Verify firewall model:

	  Verify {SERVICE_INSTANCE_NAME}_firewall, {SERVICE_INSTANCE_NAME}_packet_genrator and {SERVICE_INSTANCE_NAME}_packet_sink VMs should be created on AWS N.Virginia region.
	  
  - Verify tickclamp model:
	
      To verify that tickclamp is deployed successfully, use the following command and check that all pods are in running state on Tickclamp Server:
  
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

  - Verify nonrtric model:

	  To verify that nonrtric is deployed successfully, use the following command and check that all pods are in running state on the Nonrtric Server:
	  
	  ```sh
	  $ sudo kubectl get pods -n nonrtric
			
	  ubuntu@ip-172-31-47-62:~$ sudo kubectl get pods -n nonrtric
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

	  To verify that ric is deployed successfully, use the following command and check that all pods are in running state on Ric Server:
	  
	  ```sh		
	  $ sudo kubectl get pods -n ricplt
	  $ sudo kubectl get pods -n ricinfra 
	  $ sudo kubectl get pods -n ricxapp

	  ubuntu@ip-172-31-47-62:~$ sudo kubectl get pods -n ricplt
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
				
	  ubuntu@ip-172-31-47-62:~$ sudo kubectl get pods -n ricinfra
	  NAME                                         READY   STATUS      RESTARTS   AGE
	  tiller-secret-generator-4r45b                0/1     Completed   0          4m36s
	  deployment-tiller-ricxapp-797659c9bb-b4kdz   1/1     Running     0          4m36s		
	  ```		

  - Verify qp model:

	  To verify that qp is deployed successfully, use the following command and check that pod for qp is in running state on Ric Server:

	  ```sh
	  $ sudo kubectl get pods -n ricxapp
	    NAME                                   READY   STATUS    RESTARTS   AGE
        ricxapp-qp-dd9965f84-k2hkk             1/1     Running   0          10m
      ```
	 
  - Verify qp-driver model:

	  To verify that qp-driver is deployed successfully, use the following command and check that pod for qp-driver is in running state on Ric Server:

	  ```sh
      $ sudo kubectl get pods -n ricxapp
	    NAME                                   READY   STATUS    RESTARTS   AGE
        ricxapp-qpdriver-67bbd4d8-p9bbh        1/1     Running   0          12m
      ``` 

  - Verify ts model:

	  To verify that ts is deployed successfully, use the following command and check that pod for ts is in running state on Ric Server:

	  ```sh
      $ sudo kubectl get pods -n ricxapp
	    NAME                                   READY   STATUS    RESTARTS   AGE
        ricxapp-trafficxapp-77449f7dbc-gknb8   1/1     Running   0          14m
      ```
