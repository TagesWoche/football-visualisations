@tageswoche = @tageswoche || {}

tageswoche.data = do ->

  # used to define attributes on every action with a special condition
  specialConditionsAttr =
    "fd": "directFreeKick"
    "fi": "indirectFreeKick"
    "e" : "corner"
    "p" : "penalty"
    "ps": "penaltyShootout"
    "ew": "throwIn"
    "f" : "foul"
    "g" : "shot"
    "gegenspieler" : "opponent"

  scenes: undefined
  games: {}
  current: -1

  # param date format: 'yyyy-mm-dd' z.B. '2013-05-12'
  getStartDate: () ->
    @getUrlParameter('date')

  getUrlParameter: (name) ->
    value = RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)?[1]
    decodeURI(value) if value


  formatDate: (dateString) ->
    date = new Date(dateString)
    year = date.getFullYear()
    month = date.getMonth() + 1
    day = date.getDate()
    month = "0#{ month }" if month < 10
    day = "0#{ day }" if day < 10
    "#{ year }-#{ month }-#{ day }"

  addSceneToGame: (scene) ->
    game = @games[scene.date] ?= []
    @scenes.push(scene)
    game.push(@scenes.length - 1)

  firstScene: () ->
    lastScene = @scenes[@scenes.length - 1]
    game = @games[lastScene.date]
    @current = game[0]
    @scenes[@current]

  findScene: (date) ->
    game = @games[date]
    if game
      @current = game[0]
      @scenes[@current]

  nextScene: () ->
    @current += 1 if !@isLastScene()
    @scenes[@current]

  isLastScene: () ->
    @current == ( @scenes.length - 1 )

  previousScene: () ->
    @current -= 1 if !@isFirstScene()
    @scenes[@current]

  isFirstScene: () ->
    @current == 0

  getScene: (index) ->
    if 0 <= index && index < @scenes.length
      @scenes[index]

  gotoScene: (index) ->
    if scene = @getScene(index)
      @current = index
      scene

  nextGameScene: () ->
    game = @games[@scenes[@current].date]
    lastScene = game[game.length - 1]
    if nextScene = @getScene(lastScene + 1)
      { scene: nextScene, index: lastScene + 1 }

  previousGameScene: () ->
    game = @games[@scenes[@current].date]
    firstScene = game[0]
    if lastScenePrevGame = @getScene(firstScene - 1)
      prevGame = @games[lastScenePrevGame.date]
      { scene: @scenes[prevGame[0]], index: prevGame[0] }

  loadScenes: (callback) ->
    if @scenes
      callback(undefined, @scenes)
      return

    $.ajax(
      url: "http://tageswoche.herokuapp.com/fcb/situations",
      dataType: "jsonp"
    ).done ( data ) =>
      data = data.list

      @scenes = []
      for entry in data

        # filter out gehaltene penaltys (z.B. "g:ur")
        if !/g:/i.test(entry.scorePosition)

          for action in entry.playerPositions
            if action.specialCondition
              if action.specialCondition.toLowerCase() == 'g'
                action.shotTarget = action.triedToScore?.toLowerCase()
              action[ specialConditionsAttr[ action.specialCondition.toLowerCase() ] ] = true

          scene =
            actions: entry.playerPositions
            score: entry.score
            minute: entry.minute
            opponent: entry.opponent
            team: entry.team
            home: entry.homematch
            date: @formatDate(entry.date)
            competition: entry.competition
            scorePosition: entry.scorePosition

          if entry.scorePosition
            scorePositionParts = /(g:)?([ou])([mlr])/i.exec(entry.scorePosition)
            if scorePositionParts
              if scorePositionParts[2].toLowerCase() == "o"
                scene.highKick = true
              else
                scene.lowKick = true

          @addSceneToGame(scene)

      callback(undefined, @scenes)

    return

  loadScenesFake: (callback) ->
    data = [
      {
        score: "1:0"
        minute: 85
        date: "01.06.2012"
        opponent: "GC"
        team: "FCB"
        home: true
        tournament: "l"
        scorePosition: "OM"
        actions:
          [
            {
              name: "Stocker"
              number: 5
              positions: ["H1"]
            },
            {
              name: "Park"
              number: 8
              positions: ["E1", "C10"]
            },
            {
              name: "Streller"
              number: 10
              positions: ["E9", "A8"]
            },
            {
              name: "D. Degen"
              number: 7
              positions: ["C7"]
            }
          ]
      }, {
        score: "2:0"
        minute: 86
        date: "01.06.2012"
        opponent: "GC"
        team: "FCB"
        home: true
        tournament: "l"
        scorePosition: "UL"
        actions:
          [
            {
              name: "Frei"
              number: 11
              positions: ["H4", "F4"]
            },
            {
              name: "Park"
              number: 8
              positions: ["E6"]
            },
            {
              name: "Frei"
              number: 11
              positions: ["C5"]
            }
          ]
      }, {
        score: "1:0"
        minute: 14
        date: "01.07.2012"
        opponent: "Servette"
        team: "FCB"
        home: true
        tournament: "l"
        scorePosition: "UL"
        actions:
          [
            {
              name: "Frei"
              number: 11
              positions: ["H6"]
            },
            {
              name: "Park"
              number: 8
              positions: ["E5", "E4"]
            },
            {
              name: "Frei"
              number: 11
              positions: ["C3"]
            }
          ]
      }
    ]
    @scenes = data

    @games = {}
    newData = for entry in data
      @addSceneToGame(entry)

    callback(undefined, data)
