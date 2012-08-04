@tageswoche = @tageswoche || {}

tageswoche.data = do ->
  
  specialConditions =
    fd: "Freistoss direkt"
    fi: "Freistoss indirekt"
    e:  "Ecke"
    p:  "Penalty"
    ps: "Penaltyschiessen"
    ew: "Einwurf"
    f:  "Foul"

  scenes: undefined
  current: -1
  
  nextScene: () ->
    @current += 1 if @current < ( @scenes.length - 1 )
    @scenes[@current]
  
  previousScene: () ->
    @current -= 1 if @current > 0
    @scenes[@current]
    
  loadScenes: (callback) ->
    data = [
      {
        score: "2:1"
        minute: 85
        date: "01.06.2012"
        opponent: "GC"
        homematch: true
        competition: "l"
        playerPositions:
          [
            {
              name: "Stocker"
              number: 5
              start: "H1"
            },
            {
              name: "Park"
              number: 8
              start: "E1"
              end: "C10"
            },
            {
              name: "Streller"
              number: 10
              start: "E9"
              end: "A8"
            },
            {
              name: "D. Degen"
              number: 7
              start: "C7"
            }
          ]
      }
    ]
    
    @scenes = data
    callback(undefined, data)
    