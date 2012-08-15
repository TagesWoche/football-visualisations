@tageswoche = @tageswoche || {}

tageswoche.tableData = do ->
  templates = tageswoche.templates
  statistics: {}
  filter: {}
  data: {}
  current: "top"
  
  init: () ->
    @loadStatistics @filter, (data) =>
      @data = data
      @initEvents()
      @showTopTable()

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
    
  showGamesTable: () ->
    @current = "games"
    
    $("#stats").html(templates.tableGames({ players : @data.list }))
    $(".gradesList").sparkline('html', {
      type: 'bar'
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
          @showGamesTable()
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
    
    # build the average grade per game
    for gameGradeList in gameGrades
      count = 0
      gameGradeSum = _.reduce(gameGradeList, (sum, grade) ->
        if grade > 0
          count += 1
          sum += grade
        else
          sum
      , 0)
      console.log("sum is #{gameGradeSum} and count is #{count}")
      if count == 0
        sum.gameAverageGrades.push(0)
      else
        sum.gameAverageGrades.push(tageswoche.tableData.round(gameGradeSum / count))
      
    console.log(sum)
    sum
    
  aboveNull: (value) ->
    number = +value
    if number && number > 0
      number
    else
      ""
  
  round: (value) ->
    Math.round(value * 10) / 10
    
  aboveNullRounded: (value) ->
    @aboveNull( @round(value) )


