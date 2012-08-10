@tageswoche.templates = do ->
  table: _.template(
    """
    <table>
      <thead>
        <tr>
          <td>Spieler</td>
          <td>Einsätze</td>
          <td>Minuten</td>
          <td>Bewertung</td>
          <td>Tore</td>
          <td>Assists</td>
          <td>Gelbe</td>
          <td>Gelb-Rote</td>
          <td>Rote</td>
          <td>Bewertungs-Grafik</td>
        </tr>
      </thead>
      <tbody>
        <% _.each(players, function(player) { %>
          <tr>
            <td><%= player.name %></td>
            <td><%= player.played %></td>
            <td><%= player.minutes %></td>
            <td><%= Math.round(player.averageGrade*100)/100 %></td>
            <td><%= player.goals %></td>
            <td><%= player.assists %></td>
            <td><%= player.yellowCards %></td>
            <td><%= player.yellowRedCards %></td>
            <td><%= player.redCards %></td>
            <td class="gradesList bar">
              <% _.each(player.grades, function(grade){ %> 
                <%= grade+"," %>
              <% }); %>  
            </td>
          </tr>
        <% }); %>
      </tbody>
    </table>
    """
  )
  