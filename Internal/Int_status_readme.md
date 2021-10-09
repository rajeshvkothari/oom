# Testing

<table>
  <thead>
    <tr>
      <th colspan="2">Environment</th>
      <th colspan="3">Standalone Puccini</th>
      <th colspan="3">Tosca Docker containers</th>
	    <th colspan="3">Honolulu</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2">Models</td>
      <td>Sdwan</td>
      <td>Firewall</td>
      <td>Oran</td>
      <td>Sdwan</td>
      <td>Firewall</td>
      <td>Oran</td>
      <td>Sdwan</td>
      <td>Firewall</td>
      <td>Oran</td>
    </tr>
    <tr>
      <td colspan="2">Setup(Pre-deployment)</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
    </tr>
    <tr>
      <td colspan="2">Puccini-workflow</td>
	    <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
    </tr>
	  <tr>
      <td rowspan="2">Argo</td>
	    <td>DAG</td>
	    <td style="color:blue";>NS</td>
	    <td style="color:blue";>NS</td>
      <td style="color:blue";>NS</td>
	    <td style="color:blue";>NS</td>
      <td style="color:blue";>NS</td>
	    <td style="color:blue";>NS</td>
	    <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td>Ok</td>
    </tr>
	  <tr>
	    <td>CS</td>
	    <td style="color:blue";>NS</td>
	    <td style="color:blue";>NS</td>
      <td style="color:blue";>NS</td>
	    <td style="color:blue";>NS</td>
      <td style="color:blue";>NS</td>
	    <td style="color:blue";>NS</td>
	    <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
    </tr>
    <tr>
      <td colspan="2">Policy</td>
	    <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
      <td style="color:green";>Ok</td>
	    <td style="color:green";>Ok</td>
	    <td>Pending</td>
      <td>Pending</td>
      <td>Pending</td>
    </tr>
  </tbody>
</table>
