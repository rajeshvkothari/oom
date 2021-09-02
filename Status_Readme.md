# Testing 

<table>
  <thead>
    <tr>
      <th colspan="2">Environment</th>
      <th>Standalone Puccini</th>
      <th>Tosca Docker containers</th>
      <th>Frankfurt</th>
	  <th>Honolulu</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2">Setup(Pre-deployment)</td>
      <td>Ok</td>
      <td>Ok</td>
      <td>Ok</td>
	  <td>Ok</td>
    </tr>
    <tr>
      <td colspan="2">Workflow(Buildin)</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Ok</td>
    </tr>
    <tr>
      <td rowspan="2">Policy</td>
	  <td>Policy DAG</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Pending</td>
    </tr>
	<tr>
	  <td>Policy CS</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Pending</td>
    </tr>
	<tr>
      <td rowspan="2">Argo</td>
	  <td>Argo DAG</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Firewall model deployment issue(Withoutreposure changes)</td>
    </tr>
	<tr>
	  <td>Argo CS</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Pending</td>
    </tr>
  </tbody>
</table>
