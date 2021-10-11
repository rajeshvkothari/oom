# DEVELOPER README
Table of contents
=================
<!--ts-->
  * [Create docker images of onap components](#Create-docker-images-of-onap-components)
    * [ONAP_VID](#ONAP_VID)
	* [ONAP_SDC](#ONAP_SDC)
    * [ONAP_SO](#ONAP_SO)
    * [ONAP_AAI-Babel](#ONAP_AAI-Babel)
  * [Re deploy onap-components with our builded docker image](#Re-deploy-onap-components-with-our-builded-docker-image)
    * [ONAP-VID](#ONAP-VID)
	* [ONAP-SDC](#ONAP-SDC)
	* [ONAP-SO](#ONAP-SO)
	* [ONAP-AAI](#ONAP-AAI)
    * [ONAP-TOSCA](#ONAP-TOSCA)
    
<!--te-->

## Create docker images of onap components:

 - Create aws ubuntu 18.04 VM with following specifications:
   
   ```sh
   Instance type: t2.xlarge
   Disk: 80 GB
   Region: N. Virginia
   Security group: launch-wizard-19
   ```
	
 - **ONAP_VID**
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
	   
	 - Copy settings.xml to ~/.m2 directory
	 
	   ```sh
	   $ cd /home/ubuntu/
	   $ sudo mkdir .m2	
       $ sudo chmod -R 777 .m2
	   $ cd ~/.m2
	   #copy settings.xml from following link:
	   https://git.onap.org/oparent/plain/settings.xml
	   $ vim settings.xml
	   ```
		
	 - Git clone:
	 
	   ```sh
	   $ cd /home/ubuntu/
	   $ git clone https://github.com/customercaresolutions/onap-vid-integ -b honolulu
	   ```
	
	 - Maven build JAR:
	 
	   ```sh
	   $ cd ~/onap-vid-integ/vid-ext-services-simulator
	   $ mvn clean package
	   ```
	   
	 - Build images:
	 
	   ```sh
	   $ cd ~/onap-vid-integ
       $ mvn clean install -U -DskipTests=true -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -Dadditionalparam=-Xdoclint:none -P docker
	   ```
	   
	 - Replace sdc-tosca-1.6.0.jar at the following location and re-run the "Build images" step:
	   
	   ```sh
	   $ cd ~/.m2/repository/org/onap/sdc/sdc-tosca/sdc-tosca/1.6.0/
	   ```	    
	   
	   **NOTE : If we do not replace the sdc-tosca-1.6.0.jar then we face the following error in the VID portal :**
	   
	   ```sh
	   Error : Failed to get service models from SDC.
	   ```
	  
	 - Docker compose:
	 
	   ```sh
	   $ cd /home/ubuntu/onap-vid-integ/deliveries/src/main/docker/docker-files
	   $ docker-compose up -d
	   ```
	   
	  - Verify that images are successfully build or not:
	  
	    ```sh
		$ cd /home/ubuntu
		$ docker images
		
		Output:
		
			ubuntu@ip-172-31-40-197:~$ docker images
			REPOSITORY                      TAG                               IMAGE ID       CREATED              SIZE
			onap/vid                        7.0-STAGING-latest                ab59bd50284a   About a minute ago   719MB
			onap/vid                        8.0.2-SNAPSHOT                    ab59bd50284a   About a minute ago   719MB
			onap/vid                        8.0.2-SNAPSHOT-20211011T045636Z   ab59bd50284a   About a minute ago   719MB
			onap/vid                        8.0.2-SNAPSHOT-latest             ab59bd50284a   About a minute ago   719MB
			onap/vid                        latest                            ab59bd50284a   About a minute ago   719MB
			<none>                          <none>                            948eab334a57   About a minute ago   776MB
			onap/vid-simulator              1.0.0                             fb4f6857c866   7 minutes ago        171MB
			onap/vid-simulator              latest                            fb4f6857c866   7 minutes ago        171MB
			tomcat                          9-jdk11-openjdk-slim              e62678f8caf5   4 days ago           449MB
			openjdk                         11-jdk-slim                       068459f10b1e   12 days ago          429MB
			nexus3.onap.org:10001/openjdk   11-jdk-slim                       068459f10b1e   12 days ago          429MB
			tomcat                          jre8-alpine                       8b8b1eb786b5   2 years ago          106MB
			nexus3.onap.org:10001/tomcat    jre8-alpine                       8b8b1eb786b5   2 years ago          106MB
		```
	
     - Push and tag following images to cci-repository:
		
	   ```sh
	   onap/vid:latest 
	   ```
	   - Example :
	   
	     ```sh
	     $ docker tag onap/vid:latest rajeshvkothari/vid:0110_1544
	     $ docker push rajeshvkothari/vid:0110_1544 
		 ```
	
		
	 - Verify : open a web browser and go to the http://{IP_OF_VM}:8080/vid/login.htm page

	   NOTE : Login and password you can find in a 'fn_user' table inited by vid/epsdk-app-onap/src/main/resources/db.changelog-01.sql script.
	  
	    ```sh
	    User name: demo
	    Password: Kp8bJ4SXszM0WX
	    ```
	
 - **ONAP_SDC**
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

	 - Copy settings.xml to ~/.m2 directory
	 
	   ```sh
	   $ cd /home/ubuntu/
	   $ sudo mkdir .m2	
       $ sudo chmod -R 777 .m2
	   $ cd ~/.m2
	   #copy settings.xml from following link:
	   https://git.onap.org/oparent/plain/settings.xml
	   $ vim settings.xml
	   ```
			
     - Run following command to build sdc projects:
		
	   ```sh
	   $ cd /home/ubuntu/
	   $ export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
	   $ export PATH=$JAVA_HOME/bin:$PATH
	   ```  	
		
	 - Build images
	 
	   ```sh
	   $ cd ~/onap-sdc-integ
	   $ mvn clean install -U -P docker,fast-build -DskipTests -DskipUICleanup=true -Djacoco.skip=true -DskipPMD -Dmaven.test.skip=true -Dcheckstyle.skip
	   ```
	   
	   **Note: when we run the build image command sometimes we got an error. to overcome that error we have to re-run build image steps**
		
	 - Start Docker container
	 
	   ```sh
	   $ cd ~/onap-sdc-integ
	   $ mvn install -U -P start-sdc -DskipTests -DskipUICleanup=true -Djacoco.skip=true -DskipPMD -Dmaven.test.skip=true -Dcheckstyle.skip -e -X
	   ```
	   
	 - Replace sdc-tosca-1.6.5.jar at the following location and re-run the build images step:
	   
	   ```sh
	   $ cd ~/.m2/repository/org/onap/sdc/sdc-tosca/sdc-tosca/1.6.5/
	   ```	    
	   
	   **NOTE : If we do not replace the sdc-tosca-1.6.5.jar then we face the following error in the sdc portal :**
	   
	   ```sh
	   Error : Distribution Complate Error.
	   ```
	   
	 - Verify that images are successfully build or not:
	 
	   ```sh
	   $ cd /home/ubuntu
	   $ docker images
		
       Output:
		
	    ubuntu@ip-172-31-44-134:~$ docker images
		REPOSITORY                                          TAG                    IMAGE ID       CREATED          SIZE
		onap/sdc-simulator                                  1.8-20211011T052025Z   2ea2fe78299b   18 minutes ago   574MB
		onap/sdc-simulator                                  1.8-STAGING-latest     2ea2fe78299b   18 minutes ago   574MB
		onap/sdc-simulator                                  latest                 2ea2fe78299b   18 minutes ago   574MB
		onap/sdc-cassandra                                  1.8-20211011T052025Z   6eff85587c48   19 minutes ago   553MB
		onap/sdc-cassandra                                  1.8-STAGING-latest     6eff85587c48   19 minutes ago   553MB
		onap/sdc-cassandra                                  latest                 6eff85587c48   19 minutes ago   553MB
		onap/sdc-frontend                                   1.8-20211011T052025Z   e06ef9c017f5   19 minutes ago   626MB
		onap/sdc-frontend                                   1.8-STAGING-latest     e06ef9c017f5   19 minutes ago   626MB
		onap/sdc-frontend                                   latest                 e06ef9c017f5   19 minutes ago   626MB
		onap/sdc-cassandra-init                             1.8-20211011T052025Z   88affae8f250   22 minutes ago   1.42GB
		onap/sdc-cassandra-init                             1.8-STAGING-latest     88affae8f250   22 minutes ago   1.42GB
		onap/sdc-cassandra-init                             latest                 88affae8f250   22 minutes ago   1.42GB
		onap/sdc-backend-all-plugins                        1.8-20211011T052025Z   f2dbf1c4e8cf   23 minutes ago   680MB
		onap/sdc-backend-all-plugins                        1.8-STAGING-latest     f2dbf1c4e8cf   23 minutes ago   680MB
		onap/sdc-backend-all-plugins                        latest                 f2dbf1c4e8cf   23 minutes ago   680MB
		onap/sdc-backend-init                               1.8-20211011T052025Z   c3ffe666c0bb   23 minutes ago   196MB
		onap/sdc-backend-init                               1.8-STAGING-latest     c3ffe666c0bb   23 minutes ago   196MB
		onap/sdc-backend-init                               latest                 c3ffe666c0bb   23 minutes ago   196MB
		onap/sdc-backend                                    1.8-20211011T052025Z   1012ea78f57e   23 minutes ago   680MB
		onap/sdc-backend                                    1.8-STAGING-latest     1012ea78f57e   23 minutes ago   680MB
		onap/sdc-backend                                    latest                 1012ea78f57e   23 minutes ago   680MB
		onap/sdc-onboard-cassandra-init                     1.8-20211011T052025Z   1f3ecabef499   29 minutes ago   1.25GB
		onap/sdc-onboard-cassandra-init                     1.8-STAGING-latest     1f3ecabef499   29 minutes ago   1.25GB
		onap/sdc-onboard-cassandra-init                     latest                 1f3ecabef499   29 minutes ago   1.25GB
		onap/sdc-onboard-backend                            1.8-20211011T052025Z   78815ede825e   35 minutes ago   660MB
		onap/sdc-onboard-backend                            1.8-STAGING-latest     78815ede825e   35 minutes ago   660MB
		onap/sdc-onboard-backend                            latest                 78815ede825e   35 minutes ago   660MB
		selenium/standalone-firefox                         86.0                   cc7325d080c6   6 months ago     993MB
		nexus3.onap.org:10001/selenium/standalone-firefox   86.0                   cc7325d080c6   6 months ago     993MB
		jetty                                               9.4.31-jre11-slim      8541efe07686   13 months ago    217MB
		nexus3.onap.org:10001/jetty                         9.4.31-jre11-slim      8541efe07686   13 months ago    217MB
		onap/base_sdc-python                                1.7.0                  072878963db3   15 months ago    195MB
		nexus3.onap.org:10001/onap/base_sdc-python          1.7.0                  072878963db3   15 months ago    195MB
		onap/base_sdc-cassandra                             1.7.0                  7ae1d2a9db1d   15 months ago    553MB
		nexus3.onap.org:10001/onap/base_sdc-cassandra       1.7.0                  7ae1d2a9db1d   15 months ago    553MB
		onap/policy-jdk-debian                              2.0.1                  0853158c0e58   19 months ago    718MB
		nexus3.onap.org:10001/onap/policy-jdk-debian        2.0.1                  0853158c0e58   19 months ago    718MB
	   ```
	   
     - Push and tag following images to cci-repository:
		
	   ```sh
	   onap/sdc-onboard-backend:latest
	   onap/sdc-backend-all-plugins:latest
	   ```
	   - Example :
	   
	     ```sh
		  
		  docker tag onap/sdc-onboard-backend:latest rajeshvkothari/sdc-onboard-backend:100921_415
		  docker push rajeshvkothari/sdc-onboard-backend:100921_415			  
  
		  docker tag onap/sdc-backend-all-plugins:latest rajeshvkothari/sdc-backend-all-plugins:100921_415
		  docker push rajeshvkothari/sdc-backend-all-plugins:100921_415
		 ```	   
	   
     - You can now open the SDC UI locally:
	 
	   http://{IP_OF_VM}:8285/login

 - **ONAP_SO**
     ------------
	 
	To create SO images follow steps as follows:
	
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

	 - Copy settings.xml to ~/.m2 directory
	 
	   ```sh
	   $ cd /home/ubuntu/
	   $ sudo mkdir .m2	
       $ sudo chmod -R 777 .m2
	   $ cd ~/.m2
	   #copy settings.xml from following link:
	   https://git.onap.org/oparent/plain/settings.xml
	   $ vim settings.xml
	   ```
	   
	 - Clone git:
        
	   ```sh
	   $ cd /home/ubuntu
	   $ git clone https://github.com/customercaresolutions/onap-so-integ --branch honolulu
	   ```  	 	   
	 
	 - Build images:
	    
	   ```sh
	   cd ~/onap-so-integ
	   mvn clean install -U -DskipTests=true -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -Dadditionalparam=-Xdoclint:none -P docker
	   ```
		
     - PROBLEMS & SOLUTION :

	   - Issue:
	   
	       [ERROR] Failed to execute goal net.revelc.code.formatter:formatter-maven-plugin:2.9.0:validate (validate-java) on project common:    File'/home/ubuntu/onap-so-integ/common/src/main/java/org/onap/so/serviceinstancebeans/RequestParameters.java' has not been    previously formatted.  Please format file and commit before running validation! -> [Help 1]
		   [ERROR]
		   [ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
		   [ERROR] Re-run Maven using the -X switch to enable full debug logging.
		   [ERROR]
		   [ERROR] For more information about the errors and possible solutions, please read the following articles:
		   [ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoFailureException
		   [ERROR]
		   [ERROR] After correcting the problems, you can resume the build with the command
		   [ERROR]   mvn <goals> -rf :common
		   
	       **OR**
		   
	   - Issue:
	   
	       File 'C:\SO_CODE_FOR_CHECKIN\testforjava8\so-Java-11-upgrade1212master\common\src\main\java\org\onap\so\client\aai\AAIClient.java' has not been previously formatted. Please format file and commit before running validation! -
	
		 		 
		 - Solution:
			  
		   ```sh
	       $ mvn process-sources -P format -e
		   ```
		   
		   **Note: This command return "Build Success" message. In case, it fails re-run build images command**	
	   

	   - Issue:
	   
          [INFO] ------------------------------------------------------------------------
		  [ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.8.0:compile (default-compile) on project asdc-controller: Compilation failure
		  [ERROR] /home/ubuntu/onap-so-integ/asdc-controller/src/main/java/org/onap/so/asdc/client/ASDCController.java:[628,40] error: cannot find symbol
		  [ERROR]   symbol:   method getOriginalCsarUUID()
		  [ERROR]   location: variable iNotif of type INotificationData
			
		 - Solution:
		 
		     Remove old sdc-distribution-client-1.4.1.jar and replace new sdc-distribution-client-1.4.1.jar at following location and re-run the build images command:
			
			 ```sh
             $ cd ~/.m2/repository/org/onap/sdc/sdc-distribution-client/sdc-distribution-client/1.4.1 
			 ```
			 
	   - Issue:
	   
		  [ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.8.0:compile (default-compile) on project asdc-controller: Compilation failure
		  [ERROR] /home/ubuntu/onap-so-integ/asdc-controller/src/main/java/org/onap/so/asdc/client/ASDCController.java:[66,24] error: cannot find symbol
		  [ERROR]   symbol:   class DistributionClientFactory
		  [ERROR]   location: package org.onap.sdc.impl

	     - Solution :
			
		     Re-name sdc-distribution-client-1.4.2-SNAPSHOT.jar with sdc-distribution-client-1.4.1.jar and copy at following location and re-run the build images command:
			
			 ```sh
             $ cd ~/.m2/repository/org/onap/sdc/sdc-distribution-client/sdc-distribution-client/1.4.1 
			 ```	
			
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

	  - Replace sdc-tosca-1.6.5.jar at the following location and re-run the build images command:
	   
	    ```sh
	    $ cd ~/.m2/repository/org/onap/sdc/sdc-tosca/sdc-tosca/1.6.5/
	    ```	    
		
	  - Verify that images are successfully build or not:
	  
	    ```sh
		$ cd /home/ubuntu
		$ docker images
		
		Output:
		
		ubuntu@ip-172-31-46-163:~/onap-so-integ$ docker images
		REPOSITORY                                     TAG                            IMAGE ID       CREATED          SIZE
		onap/so/so-simulator                           1.8.0-SNAPSHOT                 f272290e322f   4 minutes ago    514MB
		onap/so/so-simulator                           1.8.0-SNAPSHOT-20211009T0521   f272290e322f   4 minutes ago    514MB
		onap/so/so-simulator                           1.8.0-SNAPSHOT-latest          f272290e322f   4 minutes ago    514MB
		onap/so/so-simulator                           latest                         f272290e322f   4 minutes ago    514MB
		onap/so/api-handler-infra                      1.8.0-SNAPSHOT                 a787778add25   5 minutes ago    550MB
		onap/so/api-handler-infra                      1.8.0-SNAPSHOT-20211009T0521   a787778add25   5 minutes ago    550MB
		onap/so/api-handler-infra                      1.8.0-SNAPSHOT-latest          a787778add25   5 minutes ago    550MB
		onap/so/api-handler-infra                      latest                         a787778add25   5 minutes ago    550MB
		onap/so/bpmn-infra                             1.8.0-SNAPSHOT                 47557f5b2e26   5 minutes ago    662MB
		onap/so/bpmn-infra                             1.8.0-SNAPSHOT-20211009T0521   47557f5b2e26   5 minutes ago    662MB
		onap/so/bpmn-infra                             1.8.0-SNAPSHOT-latest          47557f5b2e26   5 minutes ago    662MB
		onap/so/bpmn-infra                             latest                         47557f5b2e26   5 minutes ago    662MB
		onap/so/sdc-controller                         1.8.0-SNAPSHOT                 4cd4a2349c96   6 minutes ago    505MB
		onap/so/sdc-controller                         1.8.0-SNAPSHOT-20211009T0521   4cd4a2349c96   6 minutes ago    505MB
		onap/so/sdc-controller                         1.8.0-SNAPSHOT-latest          4cd4a2349c96   6 minutes ago    505MB
		onap/so/sdc-controller                         latest                         4cd4a2349c96   6 minutes ago    505MB
		onap/so/so-appc-orchestrator                   1.8.0-SNAPSHOT                 fb1184346c7c   7 minutes ago    604MB
		onap/so/so-appc-orchestrator                   1.8.0-SNAPSHOT-20211009T0521   fb1184346c7c   7 minutes ago    604MB
		onap/so/so-appc-orchestrator                   1.8.0-SNAPSHOT-latest          fb1184346c7c   7 minutes ago    604MB
		onap/so/so-appc-orchestrator                   latest                         fb1184346c7c   7 minutes ago    604MB
		onap/so/openstack-adapter                      1.8.0-SNAPSHOT                 397bdee0f55c   7 minutes ago    543MB
		onap/so/openstack-adapter                      1.8.0-SNAPSHOT-20211009T0521   397bdee0f55c   7 minutes ago    543MB
		onap/so/openstack-adapter                      1.8.0-SNAPSHOT-latest          397bdee0f55c   7 minutes ago    543MB
		onap/so/openstack-adapter                      latest                         397bdee0f55c   7 minutes ago    543MB
		onap/so/sdnc-adapter                           1.8.0-SNAPSHOT                 ab7ddc76aded   8 minutes ago    534MB
		onap/so/sdnc-adapter                           1.8.0-SNAPSHOT-20211009T0521   ab7ddc76aded   8 minutes ago    534MB
		onap/so/sdnc-adapter                           1.8.0-SNAPSHOT-latest          ab7ddc76aded   8 minutes ago    534MB
		onap/so/sdnc-adapter                           latest                         ab7ddc76aded   8 minutes ago    534MB
		onap/so/request-db-adapter                     1.8.0-SNAPSHOT                 abcaacb08606   9 minutes ago    526MB
		onap/so/request-db-adapter                     1.8.0-SNAPSHOT-20211009T0521   abcaacb08606   9 minutes ago    526MB
		onap/so/request-db-adapter                     1.8.0-SNAPSHOT-latest          abcaacb08606   9 minutes ago    526MB
		onap/so/request-db-adapter                     latest                         abcaacb08606   9 minutes ago    526MB
		onap/so/catalog-db-adapter                     1.8.0-SNAPSHOT                 688752fa41b9   9 minutes ago    523MB
		onap/so/catalog-db-adapter                     1.8.0-SNAPSHOT-20211009T0521   688752fa41b9   9 minutes ago    523MB
		onap/so/catalog-db-adapter                     1.8.0-SNAPSHOT-latest          688752fa41b9   9 minutes ago    523MB
		onap/so/catalog-db-adapter                     latest                         688752fa41b9   9 minutes ago    523MB
		onap/so/so-simulator                           1.8.0-SNAPSHOT-20211009T0508   b80c68b8a541   17 minutes ago   514MB
		onap/so/api-handler-infra                      1.8.0-SNAPSHOT-20211009T0508   126449565323   18 minutes ago   550MB
		onap/so/bpmn-infra                             1.8.0-SNAPSHOT-20211009T0508   a14fdd3f7930   18 minutes ago   662MB
		onap/so/sdc-controller                         1.8.0-SNAPSHOT-20211009T0508   5df5aa6e3dbe   19 minutes ago   505MB
		onap/so/so-appc-orchestrator                   1.8.0-SNAPSHOT-20211009T0508   2433b2a0bd2a   20 minutes ago   604MB
		onap/so/openstack-adapter                      1.8.0-SNAPSHOT-20211009T0508   90a47c59265e   21 minutes ago   543MB
		onap/so/sdnc-adapter                           1.8.0-SNAPSHOT-20211009T0508   fa98dc57e08e   21 minutes ago   534MB
		onap/so/request-db-adapter                     1.8.0-SNAPSHOT-20211009T0508   c06d046dc49a   22 minutes ago   526MB
		onap/so/catalog-db-adapter                     1.8.0-SNAPSHOT-20211009T0508   e102ada994b2   23 minutes ago   523MB
		onap/so/base-image                             1.0                            c7e9e86d103a   23 minutes ago   159MB
		adoptopenjdk/openjdk11                         jre-11.0.8_10-alpine           0507f9330a60   11 months ago    149MB
		nexus3.onap.org:10001/adoptopenjdk/openjdk11   jre-11.0.8_10-alpine           0507f9330a60   11 months ago    149MB
		ubuntu@ip-172-31-46-163:~/onap-so-integ$
		```
	 - Push and tag following images to cci-repository:
		
	   ```sh
	   onap/so/api-handler-infra:latest
	   onap/so/sdc-controller:latest
	   onap/so/catalog-db-adapter:latest
	   ```
	   - Example :
	   
	     ```sh
	     $ docker tag onap/so/api-handler-infra:latest rajeshvkothari/api-handler-infra:0910_666_ori
	     $ docker push rajeshvkothari/api-handler-infra:0910_666_ori 
		 
		 $ docker tag onap/so/sdc-controller:latest rajeshvkothari/sdc-controller:0910_666_ori
	     $ docker push rajeshvkothari/sdc-controller:0910_666_ori

		 $ docker tag onap/so/catalog-db-adapter:latest rajeshvkothari/catalog-db-adapter:0910_666_ori
		 $ docker push rajeshvkothari/catalog-db-adapter:0910_666_ori
		 
		 ```
	
 - **ONAP_AAI-Babel**
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
		
	 - Copy settings.xml to ~/.m2 directory
	 
	   ```sh
	   $ cd /home/ubuntu/
	   $ sudo mkdir .m2	
       $ sudo chmod -R 777 .m2
	   $ cd ~/.m2
	   #copy settings.xml from following link:
	   https://git.onap.org/oparent/plain/settings.xml
	   $ vim settings.xml
	   ```

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
   
## Re-deploy onap-components with our builded docker image:

 - **ONAP VID**
	 --------
	 
    **Loging into oom server**
	
	- Repalce the images in following files:
	
	  - onap-oom-integ/kubernetes/vid/templates/deployment.yaml

	    ```sh
		$ cd /onap-oom-integ/kubernetes/vid/templates/ 
		$ vim deployment.yaml
		```
		 
		```sh
		 Befor:
          containers:
           - name: {{ include "common.name" . }}
            image: 172.31.27.186:5000/onap/vid:0.3
					
		 After:
		   containers:
		   - name: {{ include "common.name" . }}
		   image: rajeshvkothari/vid:0110_1544
		```	 
	 
	- Re-deploy Steps:
 
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

 - **ONAP SDC**
     --------
	 
    **Loging into oom server**
	
	- Repalce the images in following files:
	
	  - onap-oom-integ/kubernetes/sdc/components/sdc-be/templates/deployment.yaml

	    ```sh
		$ cd /onap-oom-integ/kubernetes/sdc/components/sdc-be/templates/ 
		$ vim deployment.yaml
		```
		 
		```sh
		 Befor:
          containers:
           - name: {{ include "common.name" . }}
            image: 172.31.27.186:5000/onap/sdc-backend-all-plugins:0.3
					
		 After:
		   containers:
		   - name: {{ include "common.name" . }}
		   image: rajeshvkothari/sdc-backend-all-plugins:100921_415
		```	

	  - onap-oom-integ/kubernetes/sdc/components/sdc-onboarding-be/templates/deployment.yaml

	    ```sh
		$ cd /onap-oom-integ/kubernetes/sdc/components/sdc-onboarding-be/templates/ 
		$ vim deployment.yaml
		```
		 
		```sh
		 Befor:
          containers:
           - name: {{ include "common.name" . }}
            image: 172.31.27.186:5000/onap/sdc-onboard-backend:0.3
					
		 After:
		   containers:
		   - name: {{ include "common.name" . }}
		   image: rajeshvkothari/sdc-onboard-backend:100921_415
		```
		
	- Re-deploy Steps:	
	 	 
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
	 
 - **ONAP SO**
	 -------
	 
    **Loging into oom server**
	
	- Repalce the images in following files:
	
	  - onap-oom-integ/kubernetes/so/templates/deployment.yaml

	    ```sh
		$ cd /onap-oom-integ/kubernetes/so/templates/ 
		$ vim deployment.yaml
		```
		 
		```sh
		 Befor:
		   containers:
		   - name: {{ include "common.name" . }}
	       image: 172.31.27.186:5000/onap/so/api-handler-infra:0.3
					
		 After:
		   containers:
		   - name: {{ include "common.name" . }}
		   image: rajeshvkothari/api-handler-infra:0910_666_ori
		```
			
	  - onap-oom-integ/kubernetes/so/components/so-catalog-db/deployment.yaml
	   
	    ```sh
	    $ cd /onap-oom-integ/kubernetes/so/components/so-catalog-db/
		$ vim deployment.yaml
		```
		
		```sh
		Befor:
		   containers:
		     - name: {{ include "common.name" . }}
			 image: 172.31.27.186:5000/onap/so/catalog-db-adapter:0.3
					
		After:
		   containers:
		   - name: {{ include "common.name" . }}
		   image: rajeshvkothari/catalog-db-adapter:0910_666_ori
		```
		   
	  - onap-oom-integ/kubernetes/so/components/so-sdc-controller/deployment.yaml
	   
	    ```sh
	    $ cd /onap-oom-integ/kubernetes/so/components/so-sdc-controller/
		$ vim deployment.yaml
		```

		```sh
		Befor:
		   containers:
		   - name: {{ include "common.name" . }}
		   image: 172.31.27.186:5000/onap/so/sdc-controller:0.3
					
		After:
		   containers:
		   - name: {{ include "common.name" . }}
		   image: rajeshvkothari/sdc-controller:0910_666_ori		 
		```
	  
	- Re-deploy Steps:
	  
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

	  #If persistentvolume is not delete, fire following patch command
	  $ kubectl patch pv onap-so-sdc-controller-cci-so-sdc-csars -p '{"metadata":{"finalizers":null}}'
	
	  $ sudo rm -rf /dockerdata-nfs/onap/so
	  $ kubectl get pv,pvc | grep onap-so

	  $ kubectl patch pv onap-so-elasticsearch -p '{"metadata":{"finalizers":null}}'
		
	  $ cd ~/onap-oom-integ/kubernetes
	  $ helm deploy onap local/onap --namespace onap --create-namespace --set global.masterPassword=myAwesomePasswordThatINeedToChange -f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/environment.yaml -f onap/resources/overrides/openstack.yaml -f onap/resources/overrides/overrides.yaml --timeout 1500s
	  ```			
	
 - **ONAP AAI**
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
	
 - **ONAP TOSCA**
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
