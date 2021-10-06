# Testing

<table>
  <thead>
    <tr>
      <th colspan="2">Environment</th>
      <th>Standalone Puccini</th>
      <th>Tosca Docker containers</th>
	  <th>Honolulu</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2">Setup(Pre-deployment)</td>
      <td>Ok</td>
      <td>Ok</td>
	  <td>Ok</td>
    </tr>
    <tr>
      <td colspan="2">Workflow(Builtin)</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Ok</td>
    </tr>
    <tr>
      <td colspan="2">Policy</td>
	  <td>Ok</td>
	  <td>Ok</td>
	  <td>Pending</td>
    </tr>
	<tr>
      <td rowspan="2">Argo</td>
	  <td>DAG</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
	  <td>Ok(issue in sdwan)</td>
    </tr>
	<tr>
	  <td>CS</td>
	  <td>Not Supported</td>
	  <td>Not Supported</td>
	  <td>Ok(issue in firewall)</td>
    </tr>
  </tbody>
</table>
