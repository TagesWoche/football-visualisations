@tageswoche = @tageswoche || {}

tageswoche.tableData = do ->
  templates = tageswoche.templates
  statistics: {}
  filter: {}
  data: {}
  limit: 14
  current: "top"
  
  init: () ->
    @loadStatistics @filter, (data) =>
      @data = data
      @initEvents()
      @showTopTable()
      
    _this = @  
    $("#location-filter").on "change", (event) ->
      $this = $(@)
      _this.filter = { location: $this.val() }
      _this.loadStatistics _this.filter, (data) ->
        _this.data = data
        _this.initEvents()
        if _this.current == "top"
          _this.showTopTable()
        else
          _this.showGamesTable()
          


  getStatisticsForPopup: ->
    @statistics["all"]
        
  loadStatistics: (filter, callback) ->
    filterString = ""
    if filter.location then filterString += "location=#{filter.location}&"
    if filter.game then filterString += "game=#{filter.game}"
    if filterString == "" then filterString = "all"
    # console.log("Filter is #{filterString}")
    
    if @statistics[filterString]
      callback(@statistics[filterString])
      return
    else
      $.ajax(
        url: "http://tageswoche.herokuapp.com/fcb/statistics?#{filterString}",
        dataType: "jsonp"
      ).done ( data ) =>
        @statistics[filterString] = data
        callback(data)
      return
  
  showTopTable: () ->
    @current = "top"   
    $("#stats").html(templates.table({ players : @data.list }))
    @tablesorter()
    
  showScenesTable: () ->
    @current = "scenes"
    
    $("#stats").html(templates.tableScenes({ players : @data.list }))  
    _.each($(".scoresList"), (playerEntry, idx) =>
      $playerEntry = $(playerEntry)
      playerScores = _.chain(@data.list[idx].scores)
                        .map((scoreEntry) ->
                          scoreEntry.scores
                        )
                        .last(@limit)
                        .value()
                        
      $playerEntry.sparkline(playerScores,
        type: 'bar'
        # tooltipFormatter: (sparklines, options, fields) ->
        #          if fields[0].value == 0
        #            "Gegner #{gameNames[fields[0].offset]}. keine Bewertung"
        #          else      
        #            "Gegner #{gameNames[fields[0].offset]}. Note: #{fields[0].value} <br/>Mannschafts-Durchschnitt: #{totalValues[fields[0].offset]}"    
        height: 15
        barWidth: 12
        barSpacing: 2
      
      )
      
    )
    
    
    
    @tablesorter()
    
  showGamesTable: () ->
    @current = "games"
        
    $("#stats").html(templates.tableGames({ players : @data.list }))

    totalValues = _.chain(@data.list[0].grades)
                    .map((gradeEntry) -> 
                        tageswoche.tableData.round(gradeEntry.gameAverageGrade) 
                    )
                    .last(@limit)
                    .value()
        
    gameNames =   _.chain(@data.list[0].grades)
                    .map((gradeEntry) -> 
                        gradeEntry.opponent 
                    )
                    .last(@limit)
                    .value()
                    
      
    $("#totalGrades").sparkline(totalValues, {
      type: 'bar'
      tooltipFormatter: (sparklines, options, fields) ->
        "Gegner #{gameNames[fields[0].offset]}: #{totalValues[fields[0].offset]}"
      height: 15
      barWidth: 12
      barSpacing: 2
      colorMap:
        "": '#F6F6F6'
        "0": '#F6F6F6'
        "0.01:1": '#E92431'
        "1.01:2": '#EB4828'
        "2.01:3": '#F9892E'
        "3.01:4": '#EAE600'
        "4.01:5": '#7FC249'
        "5.01:6": '#1BA755'
    })
    
    _.each($(".gradesList"), (playerEntry, idx) =>
      $playerEntry = $(playerEntry)
      playerValues = _.chain(@data.list[idx].grades)
                        .map((gradeEntry) -> 
                            tageswoche.tableData.round(gradeEntry.grade) 
                        )
                        .last(@limit)
                        .value()
      
      $playerEntry.sparkline(playerValues,
        type: 'bar'
        tooltipFormatter: (sparklines, options, fields) ->
          if fields[0].value == 0
            "Gegner #{gameNames[fields[0].offset]}. keine Bewertung"
          else      
            "Gegner #{gameNames[fields[0].offset]}. Note: #{fields[0].value} <br/>Mannschafts-Durchschnitt: #{totalValues[fields[0].offset]}"
          
        height: 15
        barWidth: 12
        barSpacing: 2
        colorMap:
          "": '#F6F6F6'
          "0": '#F6F6F6'
          "0.01:1": '#E92431'
          "1.01:2": '#EB4828'
          "2.01:3": '#F9892E'
          "3.01:4": '#EAE600'
          "4.01:5": '#7FC249'
          "5.01:6": '#1BA755'
      
      )
      
      )
    @tablesorter()
    
  tablesorter: () ->
    $("#player-table").tablesorter(
      sortInitialOrder: "desc"
      rememberSorting: false
    )
  
  initEvents: () ->
    $("#stats").on "click", "td", (event) =>
      if $(event.target).parent().parent("tbody").length
        if @current == "top"
          #@showGamesTable()
          @showScenesTable()
        else
          @showTopTable()
  
  totals: (players) ->
    sum = { played: 0, minutes: 0, grades: [], goals: 0, assists: 0, yellowCards: 0, yellowRedCards: 0, redCards: 0, gameAverageGrades: [] }
    gameGrades = []
    for player in players
      sum.played += +player.played
      sum.minutes += +player.minutes
      if player.averageGrade > 0
        sum.grades.push(player.averageGrade)
      sum.goals += +player.goals
      sum.assists += +player.assists
      sum.yellowCards += +player.yellowCards
      sum.yellowRedCards += +player.yellowRedCards
      sum.redCards += +player.redCards
      for index, gameGrade of player.grades
        if gameGrades[index] == undefined
          gameGrades[index] = []
        gameGrades[index].push(gameGrade)  
    
    # build the grade sum over all players    
    gradeSum = _.reduce(sum.grades, (sum, grade) ->
      sum += grade
    , 0)
    sum.averageGrade = tageswoche.tableData.round(gradeSum / sum.grades.length)
    sum
    
  aboveNull: (value) ->
    number = +value
    if number && number > 0 && _.isFinite(number)
      number
    else
      ""
  
  round: (value) ->
    Math.round(value * 10) / 10
    
  aboveNullRounded: (value) ->
    @aboveNull( @round(value) )


