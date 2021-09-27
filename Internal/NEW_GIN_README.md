- **ORAN Servers**
    ------------
	
  These servers need to be created only if oran models are to be deployed.
  
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
	Security group: launch-wizard-19
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
  	  $ k3sup install --ip {PRIVATE_IP_ADDR_OF__RIC_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --context ric
  	  $ sudo mkdir ~/.kube 
      $ sudo cp /home/ubuntu/kubeconfig .kube/config
      $ sudo chmod 777 .kube/config
  	   
      # Make sure the /home/ubuntu/kubeconfig file contains an entry of cluster and context for ric.
    
      $ k3sup install --host {PRIVATE_IP_ADDR_OF_NONRTRIC_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --local-path ~/.kube/config --merge --context default
      $ k3sup install --host {PRIVATE_IP_ADDR_OF_RIC_VM} --user ubuntu --ssh-key $HOME/.ssh/cciPrivateKey --local-path ~/.kube/config --merge --context ric
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
	  
    - Copy cciPrivateKey:
	
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
