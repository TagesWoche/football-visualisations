@tageswoche = @tageswoche || {}

tageswoche.data = do ->
  
  specialConditions =
    "Freistoss direkt": "fd"
    "Freistoss indirekt": "fi"
    "Ecke": "e"
    "Penalty": "p"
    "Penaltyschiessen": "ps"
    "Einwurf": "ew"
    "Foul": "f"

  is: (condition, code) ->
    if condition && code
      specialConditions[condition] == code.toLowerCase()
    else
      false
    
  scenes: undefined
  games: {}
  current: -1
  
  addSceneToGame: (index, scene) ->
    game = @games[scene.date] ?= []
    @scenes.push(scene)
    game.push(index)
    
  firstScene: () ->
    lastScene = @scenes[@scenes.length - 1]
    game = @games[lastScene.date]
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
    @current = index
    @scenes[@current]
      
    
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
      for entry, index in data
        
        # filter out gehaltene penaltys (z.B. "g:ur")
        if !/g:/i.test(entry.scorePosition)        
          @addSceneToGame(index,
            actions: entry.playerPositions
            score: entry.score
            minute: entry.minute
            opponent: entry.opponent
            team: entry.team
            home: entry.homematch
            date: entry.date
            competition: entry.competition
            scorePosition: entry.scorePosition
          )
      
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
    newData = for entry, index in data
      @addSceneToGame(entry, index)
      
    callback(undefined, data)
    