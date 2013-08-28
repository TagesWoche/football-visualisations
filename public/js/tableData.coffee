@tageswoche = @tageswoche || {}

tageswoche.tableData = do ->
  templates = tageswoche.templates
  statistics: {}
  filter: {}
  data: {}
  limit: 14
  current: "top"

  init: () ->
    @prepareTablesorter()
    @initEvents()
    @loadStatistics(@filter, $.proxy(@redrawTable, @))

    $("#location-filter").on "change", (event) =>
      $this = $(event.currentTarget)
      @filter ?= {}
      @filter.location = $this.val()
      @loadStatistics(@filter, $.proxy(@redrawTable, @))

    $("#competition-filter").on "change", (event) =>
      $this = $(event.currentTarget)
      @filter ?= {}
      @filter.competition = $this.val()
      @loadStatistics(@filter, $.proxy(@redrawTable, @))

    $("#saison-filter").on "change", (event) =>
      $this = $(event.currentTarget)
      @filter ?= {}
      @filter.saison = $this.val()
      @loadStatistics(@filter, $.proxy(@redrawTable, @))


  redrawTable: (data) ->
    @data = data
    @drawTable(@current)

  getStatisticsForPopup: ->
    @statistics["all"]

  loadStatistics: (filter, callback) ->
    filterString = ""
    if filter.location then filterString += "location=#{filter.location}&"
    if filter.competition then filterString += "competition=#{filter.competition}&"
    if filter.saison then filterString += "saison=#{filter.saison}"
    #if filter.game then filterString += "game=#{filter.game}"
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
        #console.log data
        @statistics[filterString] = data
        callback(data)
      return

  drawTable: (tableName) ->
    @current = tableName

    $("#table-nav li a.active").removeClass("active")
    $("#table-nav li a.#{ tableName }-table").addClass("active")

    switch tableName
      when "top" then @showTopTable()
      when "games" then @showGamesTable()
      when "scenes" then @showScenesTable()

  showTopTable: () ->
    $("#stats").html(templates.table({ players : @data.list }))
    @tablesorter()

  showScenesTable: () ->
    $("#stats").html(templates.tableScenes({ players : @data.list }))
    _.each($(".scoresList"), (playerEntry, idx) =>
      $playerEntry = $(playerEntry)
      playerScores = _.chain(@data.list[idx].scores)
                        .map((scoreEntry) ->
                          scoreEntry.scores
                        )
                        .last(@limit)
                        .value()

      gameNames =   _.chain(@data.list[0].scores)
                      .map((gradeEntry) ->
                          gradeEntry.opponent
                      )
                      .last(@limit)
                      .value()

      $playerEntry.sparkline(playerScores,
        type: 'bar'
        tooltipFormatter: (sparklines, options, fields) ->
          "Gegner #{gameNames[fields[0].offset]}. <br/> Tore: #{fields[0].value}, Assists: #{fields[1].value}"
        height: 15
        barWidth: 12
        barSpacing: 2

      )
    )

    @tablesorter()

  showGamesTable: () ->
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


  prepareTablesorter: () ->
    $.tablesorter.addParser(
      id: 'position'
      is: (s) ->
        false # return false so this parser is not auto detected

      format: (value) ->
        # format your data for normalization
        value = value.toLowerCase().replace(/tw/i, 4).replace(/ve/i, 3).replace(/mf/i, 2).replace(/st/i, 1)

      type: 'numeric' # set type, either numeric or text
    )

    $.tablesorter.addParser(
      id: 'reverse'
      is: (s) ->
        false # return false so this parser is not auto detected

      format: (value) ->
        # format your data for normalization
        if value then -value else -10000000

      type: 'numeric' # set type, either numeric or text
    )

  tablesorter: () ->
    headers = switch @current
      when "top"
        1:
          sorter: "position"
      when "games"
        1:
          sorter: "position"
      when "scenes"
        5:
          sorter: "reverse"

    $("#player-table").tablesorter
      sortInitialOrder: "desc"
      rememberSorting: true
      headers: headers

  initEvents: () ->

    # direct clicks on table tds
    $("#stats").on "click", "td", (event) =>
      $this = $(event.currentTarget)

      if $this.hasClass("top-table")
        @drawTable("top")
      else if $this.hasClass("games-table")
        @drawTable("games")
      else if $this.hasClass("scenes-table")
        @drawTable("scenes")

    # table header sorting
    $("#stats").on "click", "th", (event) =>
      $this = $(event.currentTarget)

      $("#stats th").removeClass("active")
      $this.addClass("active")

    # navigation clicks
    $("#table-nav li a").on "click", (event) =>
      event.preventDefault()
      $this = $(event.currentTarget)

      if $this.hasClass("top-table")
        @drawTable("top")
      else if $this.hasClass("games-table")
        @drawTable("games")
      else if $this.hasClass("scenes-table")
        @drawTable("scenes")


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


