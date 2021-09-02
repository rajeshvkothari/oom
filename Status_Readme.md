# Testing 

| Environment             | Setup  | Workflow Micro-Service | Policy Micro-Service |       Argo-Workflow Micro-Service        |
| :---------------------- | :----: | :--------------------: | :------------------: | :--------------------------------------: |
| Standalone Puccini      | TESTED |         TESTED         |        TESTED        |     NOT TESTED/ ARGO ENV NOT AVAILABLE   |
| Tosca Docker containers | TESTED |         TESTED         |        TESTED        |     NOT TESTED/ ARGO ENV NOT AVAILABLE   |
| Frankfurt               | TESTED |         TESTED         |        TESTED        |     NOT TESTED/ ARGO ENV NOT AVAILABLE   |
| Honolulu                | TESTED |         TESTED         |        PENDING       | - Firewall model deployment issue with                                                                                       DAG based argo-template (Without                                                                                       reposure changes)<br>- Wotking on                                                                                       containerSet and DAG based                                                                                       argo-template with reposure changes    |
<table>
  <thead>
    <tr>
      <th>Environment</th>
      <th>Setup</th>
      <th>Workflow Micro-Service</th>
      <th>Policy Micro-Service</th>
	  <th>Argo-Workflow Micro-Service</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Standalone Puccini</td>
      <td>Tosca Docker containers</td>
      <td>Frankfurt</td>
      <td>Honolulu</td>
    </tr>
    <tr>
      <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
    </tr>
    <tr>
      <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
    </tr>
	<tr>
      <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
    </tr>
  </tbody>
</table>
