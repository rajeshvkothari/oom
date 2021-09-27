	  Sometimes AAI pods takes 60-80 minutes to deploy due to this SDC service distribution fails. To overcome this issue and distribute service successfully from SDC do the step as follows:

	 - Login into onap-aai-traversal pod and run following commands:
		
       ```sh
       cd /opt/app/aai-traversal/bin/install 
	   ./updateQueryData.sh aaiadmin
	   ```
	   
	   Expected output:
	    
		```sh
		Begin putTool for widget action-1.0.json
		End putTool for widget action-1.0.json
		Begin putTool for widget action-data-1.0.json
		End putTool for widget action-data-1.0.json
		Begin putTool for widget allotted-resource-1.0.json
		```
