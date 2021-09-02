# Testing 

| Environment             | Setup  | Workflow Micro-Service | Policy Micro-Service |       Argo-Workflow Micro-Service  
                                                                                           DAG     ||      containerSet       |
| :---------------------- | :----: | :--------------------: | :------------------: | :--------------------------------------: |
                                                                                  
| Standalone Puccini      | TESTED |         TESTED         |        TESTED        |           -      ||        -             |
| Tosca Docker containers | TESTED |         TESTED         |        TESTED        |           -      ||        -             |
| Frankfurt               | TESTED |         TESTED         |        TESTED        |           -      ||        -             |
| Honolulu                | TESTED |         TESTED         |        PENDING       | - Firewall model 
                                                                                      deployment issue
																					  with DAG based 
																					  argo-template 
																					  (Withoutreposure 
																					  changes)        ||     PENDING          |
