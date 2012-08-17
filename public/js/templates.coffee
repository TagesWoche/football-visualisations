@tageswoche = @tageswoche || {}

@tageswoche.templates = do ->
  
  table: _.template(
    """
    <table id="player-table">
      <colgroup>
        <col class="col-player">
        <col class="col-games">
        <col class="col-minutes">
        <col class="col-grade">
        <col class="col-goals">
        <col class="col-assists">
        <col class="col-yellow" align="center">
        <col class="col-yellow-red" align="center">
        <col class="col-red" align="center">
      </colgroup>
      <thead>
        <tr>
          <th>Spieler</th>
          <th>Einsätze</th>
          <th>Minuten</th>
          <th>&oslash; Bewertung</th>
          <th>Tore</th>
          <th>Assists</th>
          <th>Gelbe</th>
          <th>Gelb-Rote</th>
          <th>Rote</th>
        </tr>
      </thead>
      <tbody>
        <% _.each(players, function(player) { %>
          <tr>
            <td><%= player.name %></td>
            <td class="center"><%= player.played %></td>
            <td class="center"><%= tageswoche.tableData.aboveNull( player.minutes ) %></td>
            <td class="center"><%= tageswoche.tableData.aboveNullRounded( player.averageGrade ) %></td>
            <td class="center"><%= tageswoche.tableData.aboveNull( player.goals ) %></td>
            <td class="center"><%= tageswoche.tableData.aboveNull( player.assists ) %></td>
            <td class="center"><%= tageswoche.tableData.aboveNull( player.yellowCards ) %></td>
            <td class="center"><%= tageswoche.tableData.aboveNull( player.yellowRedCards ) %></td>
            <td class="center"><%= tageswoche.tableData.aboveNull( player.redCards ) %></td>
          </tr>
        <% }); %>
      </tbody>
      <tbody style="font-weight:bold;text-align:center">
        <tr>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
        </tr>
        <tr>
          <% sum = tageswoche.tableData.totals( players ) %>
          <td>Total</td>
          <td><%= sum.played %></td>
          <td><%= sum.minutes %></td>
          <td><%= sum.averageGrade %></td>
          <td><%= sum.goals %></td>
          <td><%= sum.assists %></td>
          <td><%= sum.yellowCards %></td>
          <td><%= sum.yellowRedCards %></td>
          <td><%= sum.redCards %></td>
        </tr>
      </tbody>
    </table>
    """
  )
  
  tableGames: _.template(
    """
    <table id="player-table">
      <colgroup>
        <col class="col-player">
        <col class="col-games">
        <col class="col-minutes">
        <col class="col-grade">
        <col class="col-graph">
      </colgroup>
      <thead>
        <tr>
          <th>Spieler</th>
          <th>Einsätze</th>
          <th>Minuten</th>
          <th>&oslash; Bewertung</th>
          <th>Bewertungen aller Spiele</th>
        </tr>
      </thead>
      <tbody>
        <% _.each(players, function(player) { %>
          <tr>
            <td><%= player.name %></td>
            <td class="center"><%= player.played %></td>
            <td class="center"><%= tageswoche.tableData.aboveNull( player.minutes ) %></td>
            <td class="center"><%= tageswoche.tableData.aboveNullRounded( player.averageGrade ) %></td>
            <td class="gradesList bar graph"> 
            </td>
          </tr>
        <% }); %>
      </tbody>
      <tbody style="font-weight:bold;text-align:center">
        <tr>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
        </tr>
        <tr>
          <td>Total</td>
          <td><%= sum.played %></td>
          <td><%= sum.minutes %></td>
          <td><%= sum.averageGrade %></td>
          <td class="bar graph" id="totalGrades" style="text-align: left">
          </td>
        </tr>
      </tbody>
    </table>
    """
  )
  