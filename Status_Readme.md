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
      <th colspan="2">1</th>
      <th>3</th>
      <th>4</th>
      <th>5</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="3">1</td>
      <td rowspan="2">1</td>
      <td rowspan="2" colspan="2">2</td>
      <td>6</td>
    </tr>
    <tr>
      <td>7</td>
    </tr>
    <tr>
      <td>4</td>
      <td>3</td>
      <td colspan="2">5</td>
    </tr>
  </tbody>
</table>
