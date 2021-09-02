<table>
  <thead>
    <tr>
      <th>Environment</th>
      <th>Standalone Puccini</th>
      <th>Tosca Docker containers</th>
      <th>Frankfurt</th>
	  <th colspan="2">Honolulu</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Setup</td>
      <td>OK</td>
      <td>OK</td>
      <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
    <tr>
      <td>Workflow Micro-Service</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
    <tr>
      <td>Policy Micro-Service</td>
	  <td>Policy DAG</td>
	  <td>Policy CS</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
	<tr>
      <td>Argo-Workflow Micro-Service</td>
	  <td>Argo DAG</td>
	  <td>Argo CS</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>PENDING</td>
	  <td>Firewall model deployment issue with DAG based argo-template (Withoutreposure changes)</td>
	  <td>PENDING</td>
    </tr>
  </tbody>
</table>
