1.Ganesh Mane:

--------Summary
	We are able to deploy firewall model with 'argo-workflow' type through OOM.
	 Note : Installed argo with 'containerSet' while setup OOM.

	For that, we have to use small instance name while creating 'Service Instance' through VID.

	  ----------Trial 1
	  Able to deploy firewall with following 'Service Instance' name :
		 fw_101
		 fw_102
		 
		 Note : argo template json file size in above case is 39 kb.
		 
		 
	  ----------Trial 2	 
	  VID return 'timeout' error and argo-workflow stuck in argo GUI with following 'Service Instance' name.
		 firewall_instance
		 
		 Note : argo template json file size in above case is 41 kb.

	 ----------Trial 3
	  VID return following error 
			 10/06/21 05:43:19 HTTP Status: Internal Server Error (500)
			 {
			  "requestError": {
				"serviceException": {
				  "messageId": "SVC0002",
				  "text": "Exception caught mapping Puccini JSON response to object"
			 }
	 
		  and argo-workflow failed with following error in argo GUI 
			  MESSAGE
			  error in entry template execution: etcdserver: request is too large
		  
		  with following 'Service Instance' name.
				firewall_instance_110
				firewall_instance_101


		 Note : argo template json file size in above case is 42 kb.


	We are trying to figure out why this happens. 
	Trying to figure out what we need to change while setup argo.


	We got following links related to above and we are looking into it.
		https://argoproj.github.io/argo-workflows/offloading-large-workflows/
		https://stackoverflow.com/questions/60468110/kubernetes-object-size-limitations
		https://stackoverflow.com/questions/64987175/unable-to-run-argo-workflow-due-to-an-opaque-error
		https://github.com/argoproj/argo-cd/issues/621 

2.Rupesh Shinde:

 +++++Summary

	 We are now able to store all data from tosca simple 1.3 profile in dgraph while 
	  initialization of tosca-compiler.
	 
	 There was issue while reading tosca profile before storing it in dgraph.
	 We are now working on fetching profile from dgraph during createInstance api call.
	  
	 We are looking into this.

3.Dhananjay Gahiwade:

  Today's Summary:
  
	I]Today, we created a reply for the mail and checked the pre-built images, section if we used 1(.) in the docker-compose.yml file then it works fine.

	II]Also deploy firewall, sdwan model using argo-workflow with DAG in that firewall model get deployed successfully but sdwan model does not. we are still working on it.
	
	------README update notes
	
	1]"Building images" section in "Pre Deployment Steps"
		
		- puccini/docker-compose.yaml
		
		  Replace the docker-compose.yaml to docker-compose.yml 

	2]Replace the built-in workflow with puccini-workflow in whole readme.

	3]"Using pre built images" section in "Pre Deployment Steps"

		- Replace the 2(..) with 1(.) in volumes property:
			
		  -  ./dvol/config:/opt/app/config
		  -  ./dvol/models:/opt/app/models
		  -  ./dvol/data:/opt/app/data
		  -  ./dvol/log:/opt/app/log
		  
	4]"ONAP OOM testing"

		- Need to modify note:
		
			Note : If any ONAP components return a error message as follows, eg. (SDC, VID) then open the link in a new tab of windows Browser. 

			"It looks like the webpage at https://sdc.api.fe.simpledemo.onap.org:30207/sdc1/portal might be having issues, or it may have moved permanently to a new web address."

	5]"Make changes in ~/onap-oom-integ/cci/application.cfg:" sub point in "OOM DEMO Server" section 
		
		- Need to modify note:
		
			Note3 : If ORAN servers have not been created, then keep ricServerIP and nonrtricServerIP values as is.

4.Anil Amte:

  summary+++++++++  
	Today, we build an image of the sdc Component successfully using DEVELOPER_README.md and verified it and it works fine along with that we tested the sdc re-deploy steps. link of updated DEVELOPER_README.md as follows:
	
	https://github.com/rajeshvkothari3003/oom/blob/master/Internal/DEVELOPER_README.md
  
	Note: when we run the build image command sometimes we got an error. to overcome that error we have to re-run build image steps. 


Reply for mail:
	
	1)GIN_README/docker-based section talks about updating puccini/docker-compose.yaml when building images from scratch or using prebuilt. The file name is actually puccini/docker-compose.yml (without a). Also for using the prebuilt images option, the volumes section in the docker-compose.yml has 2 (..) vs 1 (.) for build from scratch option; when I went with 1 (.), we got past the previous issue of Exited(1) status for docker containers. Please correct me if I'm wrong on these 2 points.

   volumes:

      -  ../dvol/config:/opt/app/config

      -  ../dvol/models:/opt/app/models

      -  ../dvol/data:/opt/app/data

      -  ../dvol/log:/opt/app/log
	  
		-------Reply: 
		Yes, file name is actually puccini/docker-compose.yml (without a). We updated the GIN_README.
		
		Yes, We have to use 1(.) in both th case pre-build and scratch. We updated the GIN_README for
		similar.
		We tested (.) in both th cases(pre-build and scratch) and we are able to build images
		and start containers using pre-build and scratch.
	
	

	2)When we say built-in workflow, is that (always) synonymous to puccini workflow? e.g. IMPORTANT NOTE reference in GIN_README/docker based section

		-------Reply: 
		Yes, built-in workflow is synonymous with puccini-workflow.
		We updated README for that and going forward we will only use 'puccini-workflow' name.
		

	3)GIN_README/deployment steps/oom section...so before the recent changes to oom-based section, I've been able to access the onap portal BUT getting the following error message when I click on SDC application; by any chance, have you encountered this? I haven't had a chance to try again after the changes.

	It looks like the webpage at https://sdc.api.fe.simpledemo.onap.org:30207/sdc1/portal might be having issues, or it may have moved permanently to a new web address.

		-------Reply: 
		when we click on any application like SDC, VID, etc then it returns an error msg as follows 
			
		"It looks like the webpage at https://sdc.api.fe.simpledemo.onap.org:30207/sdc1/portal might be having issues, or it may have moved permanently to a new web address." 
			
		To overcome this issue we have to open that link in a new tab of a browser then it will work. 
		

	4)GIN_README/oom-based section has been updated with reposure instructions, one of many changes; I am running into the following response which I think is an error, please correct me if I'm wrong. Have you encountered this? Should I have ignored this and moved forward? What is the expected response, if any? Couldn't find much on google. 

	ubuntu@ip-172-31-38-214:~$ reposure registry create default  --provider=simple --wait -v

	unsupported "--provider": must be "simple", "minikube", or "openshift"


		-------Reply: 
		
		Following are the results of when we fire 'reposure' commands.
		
		ubuntu@ip-172-31-17-241:~$ reposure operator install --wait
		ubuntu@ip-172-31-17-241:~$ reposure simple install --wait
		ubuntu@ip-172-31-17-241:~$ reposure registry create default  --provider=simple --wait -v
		2021/10/06 09:41:26.410  INFO [reposure.client.admin] waiting for a pod for app "reposure-surrogate-default"
		2021/10/06 09:41:38.425  INFO [reposure.client.admin] container "surrogate" ready for pod "reposure-surrogate-default"
		2021/10/06 09:41:38.425  INFO [reposure.client.admin] a pod is available for app "reposure-surrogate-default"
		
		As we see the result of the "reposure registry create default  --provider=simple --wait -v" command in that "reposure-surrogate-default" pod is available for us.

		In your case, you maybe do something wrong while setup please check that reposure simple is installed properly or not.  


	5)GIN_README/oom-based section mentions changes to ~/onap-oom-integ/cci/application.cfg; do we still need to update argoWorkflow section accordingly, even though e.g. just deploying sdwan? 

		-------Reply:
		We udpated GIN_README yesterday and we removed different setup of application.cfg from 
		readme. 
		Added generic setup so both 'puccini-workflow' and 'argo-workflow' will 
		work in a single setup.
		
		Refer note in 'Building Tosca Model Csars' section.
		Now tosca model - metadata includes which workflow engine will be used.
		
		

	6)GIN_README/oom-based section added steps to setup ARGO; do we still need this even though e.g. just deploying sdwan?

		-------Reply:
		If we want to deploy sdwan(or any model) with 'argo-workflow' then we have to setup ARGO.
		

	7)GIN_README/deployment steps/docker based section, whenever we use any of the following, this would ONLY be applicable when ORAN models/puccini workflow are to be deployed, is that correct?

	POST http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/*
	DELETE http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/* 
	GET http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/* 

		-------Reply:
		No, following is the GENERIC API applicable for all models(with 'puccini-workflow' and 
		'argo-workflow').
		
			POST http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/*
			
		We haven't given following APIs in GIN_README. 	
			DELETE http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/* 
			GET http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/* 
			
		If you are talking about following APIs from GIN_README then it's only
		applicable for firewall model.
		
		Stop Policy(This is valid only for the firewall model):
			DELETE http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/{INSTANCE_NAME}/policy/packet_volume_limiter

		   Get Policies(This is valid only for the firewall model):
			GET http://{IP_ADDR_OF_DEMO_SERVER}:10000/bonap/templates/{INSTANCE_NAME}/policies	
