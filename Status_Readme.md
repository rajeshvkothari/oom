# Testing

Here is the status of all the conditions: 

| Environment             | Setup  | Workflow Micro-service | Policy Micro-service |       Argo-Workflow Micro-service        |
| :---------------------- | :----: | :--------------------: | :------------------: | :--------------------------------------: |
| Standalone Puccini      | TESTED |         TESTED         |        TESTED        |     NOT TESTED/ ARGO ENV NOT AVAILABLE   |
| tosca Docker containers | TESTED |         TESTED         |        TESTED        |     NOT TESTED/ ARGO ENV NOT AVAILABLE   |
| Frankfurt               | TESTED |         TESTED         |        TESTED        |     NOT TESTED/ ARGO ENV NOT AVAILABLE   |
| Honolulu                | TESTED |         TESTED         |        PENDING       | - Firewall model deployment issue wit DAG                                                                                    <br>- cciPrivateKey issue in ContainerSet                                                                                       with reposure changes                  |
