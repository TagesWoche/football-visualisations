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
        score: "1:0"
        minute: 85
        date: "01.06.2012"
        oponent: "GC"
        home: true
        tournament: "l"
        actions:
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
      }, {
        score: "2:0"
        minute: 86
        date: "01.06.2012"
        oponent: "GC"
        home: true
        tournament: "l"
        actions:
          [
            {
              name: "Frei"
              number: 11
              start: "H4"
              end: "F4"
            },
            {
              name: "Park"
              number: 8
              start: "E6"
            },
            {
              name: "Frei"
              number: 11
              start: "C5"
            }
          ]
      }
    ]
    @scenes = data
    console.log(@scenes)
    callback(undefined, data)
    