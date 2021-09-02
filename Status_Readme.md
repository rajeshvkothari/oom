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
      <th rowspan="2">Environment</th>
      <th rowspan="2">Setup</th>
      <th rowspan="2">Workflow Micro-Service</th>
      <th rowspan="2">Policy Micro-Service</th>
      <th colspan="2">Argo-Workflow Micro-Service</th>
    </tr>
  </thead>
  <tbody>
    <tr>
	  <td></td>
      <td></td>
      <td></td>
      <td></td>
	  <td>DAG</td>
	  <td>containerSet</td>
	</tr>
    <tr>
      <td>Standalone Puccini</td>
      <td>OK</td>
      <td>OK</td>
      <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
    <tr>
      <td>Tosca Docker containers</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
    <tr>
      <td>Frankfurt</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
	<tr>
      <td>Honolulu</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>PENDING</td>
	  <td>Firewall model deployment issue with DAG based argo-template (Withoutreposure changes)</td>
	  <td>PENDING</td>
    </tr>
  </tbody>
</table>
