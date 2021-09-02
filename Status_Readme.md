<table>
  <thead>
    <tr>
      <th colspan="2">Environment</th>
	  <td></td>
      <th>Standalone Puccini</th>
      <th>Tosca Docker containers</th>
      <th>Frankfurt</th>
	  <th colspan="2">Honolulu</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Setup</td>
	  <td></td>
      <td>OK</td>
      <td>OK</td>
      <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
    <tr>
      <td>Workflow Micro-Service</td>
	  <td></td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
    <tr>
      <td rowspan="2">Policy Micro-Service</td>
	  <td>Policy DAG</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
	<tr>
	  <td>Policy CS</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
    </tr>
	<tr>
      <td rowspan="2">Argo-Workflow Micro-Service</td>
	  <td>Argo DAG</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>PENDING</td>
	  <td>Firewall model deployment issue with DAG based argo-template (Withoutreposure changes)</td>
	  <td>PENDING</td>
    </tr>
	<tr>
	  <td>Argo CS</td>
	  <td>OK</td>
	  <td>OK</td>
	  <td>PENDING</td>
	  <td>Firewall model deployment issue with DAG based argo-template (Withoutreposure changes)</td>
	  <td>PENDING</td>
    </tr>
  </tbody>
</table>
