@tageswoche = @tageswoche || {}

@tageswoche.templates = do ->

  table: _.template(
    """
    <h2>Saison <%= season %></h2>
    <table id="player-table">
      <colgroup>
        <col class="col-player">
        <col class="col-position">
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
          <th class="headerSortDown">Position*</th>
          <th>Einsätze</th>
          <th>Minuten</th>
          <th>&oslash; Bewertung</th>
          <th>Tore</th>
          <th>Assists</th>
          <th class="hide-mobile">Gelbe</th>
          <th class="hide-mobile">Gelb-Rote</th>
          <th class="hide-mobile">Rote</th>
        </tr>
      </thead>
      <tbody>
        <% _.each(players, function(player) { %>
          <tr>
            <td><%= player.name %></td>
            <td class="center td-position"><%= player.position %></td>
            <td class="center games-table"><%= player.played %></td>
            <td class="center games-table"><%= tageswoche.tableData.aboveNull( player.minutes ) %></td>
            <td class="center games-table"><%= tageswoche.tableData.aboveNullRounded( player.averageGrade ) %></td>
            <td class="center scenes-table"><%= tageswoche.tableData.aboveNull( player.goals ) %></td>
            <td class="center scenes-table"><%= tageswoche.tableData.aboveNull( player.assists ) %></td>
            <td class="hide-mobile center"><%= tageswoche.tableData.aboveNull( player.yellowCards ) %></td>
            <td class="hide-mobile center"><%= tageswoche.tableData.aboveNull( player.yellowRedCards ) %></td>
            <td class="hide-mobile center"><%= tageswoche.tableData.aboveNull( player.redCards ) %></td>
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
          <td class="hide-mobile"></td>
          <td class="hide-mobile"></td>
          <td class="hide-mobile"></td>
        </tr>
        <tr>
          <% sum = tageswoche.tableData.totals( players ) %>
          <td>Total</td>
          <td></td>
          <td></td>
          <td></td>
          <td><%= sum.averageGrade %></td>
          <td><%= sum.goals %></td>
          <td><%= sum.assists %></td>
          <td class="hide-mobile"><%= sum.yellowCards %></td>
          <td class="hide-mobile"><%= sum.yellowRedCards %></td>
          <td class="hide-mobile"><%= sum.redCards %></td>
        </tr>
      </tbody>
    </table>
    <br/>
    <small class="legend">* TW: Tor, VE: Verteidigung, MF: Mittelfeld, ST: Sturm</small>
    <small class="last-update">Letztes update: <%= lastUpdate.fromNow() %></small>
    """
  )

  tableGames: _.template(
    """
    <h2>Saison <%= season %></h2>
    <table id="player-table">
      <colgroup>
        <col class="col-player">
        <col class="col-position">
        <col class="col-games">
        <col class="col-minutes">
        <col class="col-grade">
        <col class="col-graph">
      </colgroup>
      <thead>
        <tr>
          <th>Spieler</th>
          <th class="headerSortDown">Position*</th>
          <th>Einsätze</th>
          <th>Minuten</th>
          <th>&oslash; Bewertung</th>
          <th class="graph-column">Bewertung letzte Spiele</th>
        </tr>
      </thead>
      <tbody>
        <% _.each(players, function(player) { %>
          <tr>
            <td><%= player.name %></td>
            <td class="center td-position"><%= player.position %></td>
            <td class="center top-table"><%= player.played %></td>
            <td class="center top-table"><%= tageswoche.tableData.aboveNull( player.minutes ) %></td>
            <td class="center top-table"><%= tageswoche.tableData.aboveNullRounded( player.averageGrade ) %></td>
            <td class="gradesList bar graph graph-column">
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
          <td class="graph-column"></td>
        </tr>
        <tr>
          <td>Total</td>
          <td></td>
          <td></td>
          <td></td>
          <td><%= sum.averageGrade %></td>
          <td class="bar graph graph-column" id="totalGrades" style="text-align: left">
          </td>
        </tr>
      </tbody>
    </table>
    <br/>
    <small class="legend">* TW: Tor, VE: Verteidigung, MF: Mittelfeld, ST: Sturm</small>
    <small class="last-update">Letztes update: <%= lastUpdate.fromNow() %></small>
    """
  )

  tableScenes: _.template(
    """
    <h2>Saison <%= season %></h2>
    <table id="player-table">
      <colgroup>
        <col class="col-player">
        <col class="col-games">
        <col class="col-goals">
        <col class="col-assists">
        <col class="col-scores">
        <col class="col-scoresperminute">
        <col class="col-graph">
      </colgroup>
      <thead>
        <tr>
          <th>Spieler</th>
          <th>Einsätze</th>
          <th>Tore</th>
          <th>Assists</th>
          <th>Scorerpunkte*</th>
          <th>Minuten pro Scorerpunkt</th>
          <th class="graph-column">Letzte Spiele</th>
        </tr>
      </thead>
      <tbody>
        <% _.each(players, function(player) { %>
          <tr>
            <td><%= player.name %></td>
            <td class="center games-table"><%= player.played %></td>
            <td class="center top-table"><%= tageswoche.tableData.aboveNull( player.goals ) %></td>
            <td class="center top-table"><%= tageswoche.tableData.aboveNullRounded( player.assists ) %></td>
            <td class="center top-table"><%= tageswoche.tableData.aboveNullRounded( player.goals + player.assists ) %></td>
            <td class="center top-table"><%= tageswoche.tableData.aboveNullRounded( player.minutes / (player.goals + player.assists) ) %></td>
            <td class="scoresList bar graph graph-column"></td>
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
          <td class="graph-column"></td>
        </tr>
        <tr>
          <% sum = tageswoche.tableData.totals( players ) %>
          <td>Total</td>
          <td></td>
          <td><%= sum.goals %></td>
          <td><%= sum.assists %></td>
          <td><%= sum.goals + sum.assists %></td>
          <td><%= tageswoche.tableData.aboveNullRounded(sum.minutes / (sum.goals + sum.assists)) %></td>
          <td class="bar graph graph-column" id="totalScores" style="text-align: left">
          </td>
        </tr>
      </tbody>
    </table>
    <br>
    <small class="legend">* Tore und Assists zusammengezählt</small>
    <small class="last-update">Letztes update: <%= lastUpdate.fromNow() %></small>
    """
  )

