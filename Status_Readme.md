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
	  <th colspan="2">Argo-Workflow Micro-Service</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Standalone Puccini</td>
      <td>TESTED</td>
      <td>TESTED</td>
      <td>TESTED</td>
	  <td>DAG</td>
	  <td>containerSet</td>
	  <td>
    </tr>
    <tr>
      <td>Tosca Docker containers</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>  -   </td>
	  <td>  -   </td>
    </tr>
    <tr>
      <td>Frankfurt</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>  -   </td>
	  <td>  -   </td>
    </tr>
	<tr>
      <td>Honolulu</td>
	  <td>TESTED</td>
	  <td>TESTED</td>
	  <td>PENDING</td>
	  <td>Firewall model deployment issue with DAG based argo-template (Withoutreposure changes)</td>
	  <td>PENDING</td>
    </tr>
  </tbody>
</table>
