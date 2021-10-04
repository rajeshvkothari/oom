# DEVELOPER README
Table of contents
=================
<!--ts-->
  * [Create docker images of onap componants](#Create-docker-images-of-onap-componants)
    * [VID](#VID)
    * [AAI-Babel](#AAI-Babel)
    * [SDC](#SDC)
    * [SO](#SO)
  * [Re deploy onap-componants with our builded docker image](#Re-deploy-onap-componants-with-our-builded-docker-image)
    * [AAI](#AAI)
    * [SO](#SO)
    * [VID](#VID)
    * [TOSCA](#TOSCA)
    * [SDC](#SDC)
<!--te-->

## Create docker images of onap componants:

 - Create aws ubuntu 18.04 VM with following specifications:
   
   ```sh
   Instance type: t2.xlarge
   Disk: 80 GB
   Region: N. Virginia
   Security group: launch-wizard-19
   ```
	
 - **VID**
     ---
	 
	Follow the following steps:
	
     - Setup jdk8:
	 
       ```sh
       $ sudo apt-get update
       $ sudo apt-get install openjdk-8-jdk
       $ java -version
       $ export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
       $ export PATH=$JAVA_HOME/bin:$PATH
       ```
	 - Setup docker:
	 
	   ```sh
	   $ sudo apt update
	   $ sudo apt-get remove docker docker-engine docker.io
	   $ sudo apt install docker.io
	   $ sudo apt  install docker-compose
	   $ sudo systemctl start docker
	   $ sudo systemctl enable docker
	   $ sudo chmod 777 /var/run/docker.sock
	   $ docker --version
	   ```
		
	   - Verify that docker is installed properly:
	     
         ```sh
         $ docker ps
         ```	
		
	     **Note : If above steps are not worked refer**
		
		   ```sh
		   https://dzone.com/articles/how-to-install-docker-on-ubuntu1804
		   ```
	
	 -  Setup maven:
	    
	    ```sh
	    $ sudo apt install maven
	    $ mvn -version
	    ```
		
	 - Setup yarn:
	   
	   ```sh
	   $ sudo apt install npm
       $ sudo npm install --global yarn@1.7.0
	   ```
	   
	 - Copy settings.xml from https://git.onap.org/oparent/plain/settings.xml to ~/.m2 directory
	  		 
	   **IMPORTANT NOTE: If .m2 directory is not available, then follows**
	
	    ```sh
	    $ mvn
	    ```
		**Note : It will return error.**
		
	 - Git clone:
	 
	   ```sh
	   $ https://github.com/onap/vid --branch honolulu
	   ```
	
	 - Maven build JAR:
	 
	   ```sh
	   $ cd ~/vid/vid-ext-services-simulator
	   $ mvn clean package
	   ```

	 - Replace sdc-tosca-1.6.5.jar at following location:
	   
	   ```sh
	   $ cd ~/.m2/repository/org/onap/sdc/sdc-tosca/sdc-tosca/1.6.0/
	   ```
	   
	 - Build images:
	 
	   ```sh
	   $ cd ~/vid
       $ mvn clean install -U -DskipTests=true -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -Dadditionalparam=-Xdoclint:none -P docker
	   ```
	   
	 - Docker compose:
	 
	   ```sh
	   $ cd /home/ubuntu/vid/deliveries/src/main/docker/docker-files
	   $ docker-compose up -d
	   ```
	   
 - **AAI-Babel**
	 ------------------- 
	 
	Follow the following steps:
	 
	 - Setup jdk 11:
	 
	   ```sh
	   $ sudo apt-get update
	   $ sudo apt-get install openjdk-11-jdk
	   $ java -version
	   $ export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
	   $ export PATH=$JAVA_HOME/bin:$PATH
	   ```
		
	 - Setup docker:
	 
	   ```sh	
	   $ sudo apt update
	   $ sudo apt-get remove docker docker-engine docker.io
	   $ sudo apt install docker.io
	   $ sudo systemctl start docker
       $ sudo systemctl enable docker
	   $ sudo chmod 777 /var/run/docker.sock
	   $ docker --version
	   ``` 
		
	   - Verify that docker is installed properly:
	
		 ```sh
		 $ docker ps
		 ```
		
	     **Note : If above steps are not worked refer**
		
		   ```sh
		   https://dzone.com/articles/how-to-install-docker-on-ubuntu1804
		   ```
		
	 - Setup maven:
	
	   ```sh
	   $ sudo apt install maven
	   $ mvn -version
	   ```
		
	 - Setup npm:
	 
	   ```sh
	   $ sudo apt install npm
	   $ sudo npm install -g npm@6.11.3
	   ```
		
	 - Git Clone:
	 
	   Check whethet already present
		
	   https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-18-04-quickstart
	
	   - Clone aai-babel repository of honolulu version:
		
		 ```sh
		 $ cd ~/
	     $ git clone https://github.com/onap/aai-babel --branch honolulu
		 ```
		
	 - Copy settings.xml from ~/.m2 directory local machine to ~/.m2 of aws ubuntu machine:
		   		 
	   **IMPORTANT NOTE: If .m2 directory is not available, then follows**
	
		 ```sh
		 $ mvn  
		 ```
		**Note : It will return error.**

	 - Modify following file to add debug port:

	   Expose port in  /home/ubuntu/aai-babel/src/main/docker/Dockerfile:
		 
	   ```sh
	   EXPOSE 8001
	   CMD ["/opt/app/babel/bin/start.sh"]
	   ```
	
	 - Add jvm arguments in /home/ubuntu/aai-babel/src/main/bin/start.sh:
	    
	   ```sh
	   PROPS="-DAPP_HOME=${APP_HOME}"
	   PROPS="${PROPS} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8001 -Dcom.sun.management.jmxremote.rmi.port=8001 -Dlogging.level.org.springframework=TRACE -Dlogging.level.org.onap.so=TRACE"
	   ```
		
     - Change the following mvn.jaxb2.version in aai-babel/pom.xml file:
	    
	   ```sh
	   Befor:
		  <!-- Dependency Versions -->
		  <mvn.jaxb2.version>0.13.3</mvn.jaxb2.version>   
			
	   After:
		  <!-- Dependency Versions -->
		  <mvn.jaxb2.version>0.14.0</mvn.jaxb2.version>
		  ```
	   
     - Build images:
	
	   ```sh
	   $ cd ~/aai-babel
	   $ mvn clean install -U -DskipTests=true -DskipUICleanup=true -Djacoco.skip=true -DskipPMD -Dmaven.test.skip=true -Dcheckstyle.skip -P docker
	   ```
		
 - **SDC**
	 -------------
	 
	 Follow the following steps:
	
	 - Setup jdk 11
		
	   ```sh
	   $ sudo apt-get update
	   $ sudo apt-get install openjdk-11-jdk
	   $ java -version
	   $ export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
	   $ export PATH=$JAVA_HOME/bin:$PATH
	   ```
		
	 - Setup docker
		
	   ```sh
	   $ sudo apt update
	   $ sudo apt-get remove docker docker-engine docker.io
	   $ sudo apt install docker.io
	   $ sudo systemctl start docker
	   $ sudo systemctl enable docker
	   $ sudo chmod 777 /var/run/docker.sock
	   $ docker --version
	   ```
		
	   - Verify that docker is installed properly:
			
		```sh
		$ docker ps
		```
		
	     **Note : If above steps are not worked refer:**
		
		  ```sh
           https://dzone.com/articles/how-to-install-docker-on-ubuntu1804
          ```
			
	 - Setup maven:
	 
	   ```sh
	   $ sudo apt install maven
	   $ mvn -version
	   ```
	 - Setup npm:
		
	   ```sh
	   $ sudo apt install npm		
	   $ sudo npm install -g npm@6.14.15
	   ```
	
     - Clone sdc repository of honolulu version:
	
	   ```sh
	   $ cd ~/
	   $ git clone https://github.com/customercaresolutions/onap-sdc-integ --branch honolulu
       ```

     - Copy setting.xml from /.m2 directory local machine to /.m2 of aws ubuntu machine

	   **IMPORTANT NOTE: If .m2 directory is not available, then follows**
	
	    ```sh
        $ mvn
	    ```
		**Note : It will return error.**
			
     - Run following command to build sdc projects:
		
	   ```sh
	   export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
	   export PATH=$JAVA_HOME/bin:$PATH
	   ```

	 - Replace sdc-tosca-1.6.5.jar at following location:
	   
	   ```sh
	   $ cd ~/.m2/repository/org/onap/sdc/sdc-tosca/sdc-tosca/1.6.5/
	   ```	   	
		
	 - Build images
	 
	   ```sh
	   $ cd ~/onap-sdc-integ
	   $ mvn clean install -U -P docker,fast-build -DskipTests -DskipUICleanup=true -Djacoco.skip=true -DskipPMD -Dmaven.test.skip=true -Dcheckstyle.skip
	   ```
		
	 - Start Docker container
	 
	   ```sh
	   mvn install -U -P start-sdc -DskipTests -DskipUICleanup=true -Djacoco.skip=true -DskipPMD -Dmaven.test.skip=true -Dcheckstyle.skip -e -X
	   ```

     - You can now open the SDC UI locally:
	 
	   http://{IP_OF_VM}:8285/login

     - fire docker images command and add output here
   
 - **SO**
     ------------
	 
	Follow the following steps:
	
	 - Setup jdk8:

	   ```sh
	   $ sudo apt-get update
	   $ sudo apt-get install openjdk-11-jdk
       $ java -version
	   $ export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
	   $ export PATH=$JAVA_HOME/bin:$PATH
	   ```
		
	 - Setup docker:
		
	   ```sh
	   $ sudo apt update
	   $ sudo apt-get remove docker docker-engine docker.io
	   $ sudo apt install docker.io
	   $ sudo apt  install docker-compose
	   $ sudo systemctl start docker
	   $ sudo systemctl enable docker
	   $ sudo chmod 777 /var/run/docker.sock
	   $ docker --version
	   ```
		
	   - Verify that docker is installed properly:
		 
		 ```sh 
		 $ docker ps
		 ```
		 
	     **Note : If above steps are not worked refer**
		
		   ```sh
		   https://dzone.com/articles/how-to-install-docker-on-ubuntu1804
		   ```	  
	
	 - Setup maven:
		
	   ```sh
	   $ sudo apt install maven
	   $ mvn -version
	   ```
		
	 - Setup yarn:
		
	   ```sh
	   $ sudo apt install npm
	   $ sudo npm install --global yarn@1.7.0
	   ```
		
	 - Copy settings.xml from ~/.m2 directory local machine to ~/.m2 of aws ubuntu machine:
		 
	  		 
	   **IMPORTANT NOTE: If .m2 directory is not available, then follows**
	
	   ```sh
	   $ mvn  
	   ```
	   **Note : It will return error.**		
		
	 - Clone git:
        
	   ```sh
	   $ cd /home/ubuntu
	   $ git clone https://github.com/customercaresolutions/onap-so-integ --branch honolulu
	   ```  
   
	 - Replace sdc-tosca-1.6.5.jar at following location:
	   
	   ```sh
	   $ cd ~/.m2/repository/org/onap/sdc/sdc-tosca/sdc-tosca/1.6.5/
	   ```	 	   
	 
	 - Build images
	    
	   ```sh
	   cd ~/onap-so-integ
	   mvn clean install -U -DskipTests=true -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -Dadditionalparam=-Xdoclint:none -P docker
	   ```
		
       - PROBLEMS & SOLUTION

	     - Issue:
			
	       [INFO] mso-infrastructure-bpmn ............................ FAILURE [ 35.124 s]
		   [ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.6.1:testCompile (test-compile) on project mso-infrastructure-bpmn: Compilation failure: Compilation failure:
		   [ERROR] /home/ubuntu/onap-so-integ/bpmn/mso-infrastructure-bpmn/src/test/java/org/onap/so/bpmn/vcpe/DoCreateAllottedResourceTXCRollbackIT.java:[21,29] package org.onap.so.bpmn.mock does not exist

	     - Solution:
				
	 	   ```sh
		   $ sudo rm -R /home/ubuntu/onap-so-integ/bpmn/mso-infrastructure-bpmn/src/test
		   ``` 
				
	     - For temparory purpose we deleted /home/ubuntu/onap-so-integ/bpmn/mso-infrastructure-bpmn/src/test folder from our workspace
 
         - Run following command to restart build from where it was stop:  
	    
		     ```sh
		     $ mvn clean install -U -DskipTests=true -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -Dadditionalparam=-Xdoclint:none -P docker -rf :mso-infrastructure-bpmn
		     ```

	     - Issue:
			
	       File 'C:\SO_CODE_FOR_CHECKIN\testforjava8\so-Java-11-upgrade1212master\common\src\main\java\org\onap\so\client\aai\AAIClient.java' has not been previously formatted. Please format file and commit before running validation! -
	
         - Solution:
			  
		   ```sh
	       $ mvn process-sources -P format -e
		   ```
## Re-deploy onap-componants with our builded docker image:
    
 - **AAI**
     --------
	 
	Follow the following steps:
	
	 ```sh
	 $ cd ~/onap-oom-integ/kubernetes
	 $ make SKIP_LINT=TRUE aai; make SKIP_LINT=TRUE onap
		  
     #Using make command chart for aai gets build.

	 $ helm ls --all-namespaces
	 #OR
     $ helm ls -A
		
     # Delete release
	 $ helm uninstall onap-aai -n onap
		
	 #Wait till all pods are goes off from Terminating state
	 $ kubectl get pods -n onap | grep onap-aai			
	
	 $ sudo rm -rf /dockerdata-nfs/onap/aai
	 $ kubectl get pv,pvc | grep onap-aai

	 $ kubectl patch pv onap-aai-elasticsearch -p '{"metadata":{"finalizers":null}}'
		
	 $ cd ~/onap-oom-integ/kubernetes
	 $ helm deploy onap local/onap --namespace onap --create-namespace --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 1500s
	```	
	
 - **SO**
	 -------
	 
	Follow the following steps:
	 
	```sh
	 $ cd ~/onap-oom-integ/kubernetes
	 $ make SKIP_LINT=TRUE so; make SKIP_LINT=TRUE onap
		  
     #Using make command chart for so gets build.

	 $ helm ls --all-namespaces
		 #OR
	 $ helm ls -A
		
	 # Delete release
	 $ helm uninstall onap-so -n onap
		
	 #Wait till all pods are goes off from Terminating state
	 $ kubectl get pods -n onap | grep onap-so			
	
	 $ sudo rm -rf /dockerdata-nfs/onap/so
	 $ kubectl get pv,pvc | grep onap-so

	 $ kubectl patch pv onap-so-elasticsearch -p '{"metadata":{"finalizers":null}}'
		
	 $ cd ~/onap-oom-integ/kubernetes
	 $ helm deploy onap local/onap --namespace onap --create-namespace --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 1500s
	```			
	
 - **VID**
	 --------
	 
	 Follow the following steps:
 
	```sh
	 $ cd ~/onap-oom-integ/kubernetes
	 $ make SKIP_LINT=TRUE vid; make SKIP_LINT=TRUE onap
		  
     #Using make command chart for vid gets build.

	 $ helm ls --all-namespaces
		 #OR
	 $ helm ls -A
		
	 # Delete release
	 $ helm uninstall onap-vid -n onap
		
	 #Wait till all pods are goes off from Terminating state
	 $ kubectl get pods -n onap | grep onap-vid			
	
	 $ sudo rm -rf /dockerdata-nfs/onap/vid
	 $ kubectl get pv,pvc | grep onap-vid

	 $ kubectl patch pv onap-vid-elasticsearch -p '{"metadata":{"finalizers":null}}'
		
	 $ cd ~/onap-oom-integ/kubernetes
	 $ helm deploy onap local/onap --namespace onap --create-namespace --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 1500s
	```	
		
 - **TOSCA**
	 ----------
	 
	Follow the following steps:
 
	```sh
	 $ cd ~/onap-oom-integ/kubernetes
	 $ make SKIP_LINT=TRUE tosca; make SKIP_LINT=TRUE onap
		  
     #Using make command chart for tosca gets build.

	 $ helm ls --all-namespaces
		 #OR
	 $ helm ls -A
		
	 # Delete release
	 $ helm uninstall onap-tosca -n onap
		
     #Wait till all pods are goes off from Terminating state
     $ kubectl get pods -n onap | grep onap-tosca			
	
	 $ sudo rm -rf /dockerdata-nfs/onap/tosca
	 $ kubectl get pv,pvc | grep onap-tosca

	 $ kubectl patch pv onap-tosca-elasticsearch -p '{"metadata":{"finalizers":null}}'
		
	 $ cd ~/onap-oom-integ/kubernetes
	 $ helm deploy onap local/onap --namespace onap --create-namespace --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 1500s
	```	
	
 - **SDC**
     --------
	 
	 Follow the following steps:
 
     ```sh
	 $ cd ~/onap-oom-integ/kubernetes
	 $ make SKIP_LINT=TRUE sdc; make SKIP_LINT=TRUE onap
		  
     #Using make command chart for sdc gets build.

	 $ helm ls --all-namespaces
		 #OR
	 $ helm ls -A
		
	 # Delete release
	 $ helm uninstall onap-sdc -n onap
		
	 #Wait till all pods are goes off from Terminating state
	 $ kubectl get pods -n onap | grep onap-sdc			
	
	 $ sudo rm -rf /dockerdata-nfs/onap/sdc
	 $ kubectl get pv,pvc | grep onap-sdc

	 $ kubectl patch pv onap-sdc-elasticsearch -p '{"metadata":{"finalizers":null}}'
		
	 $ cd ~/onap-oom-integ/kubernetes
	 $ helm deploy onap local/onap --namespace onap --create-namespace --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 1500s
	 ```	
