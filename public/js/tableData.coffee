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
    $("#player-table").tablesorter({ sortInitialOrder: "desc" })
  
  initEvents: () ->
    $("#stats").on "click", "td", (event) =>
      if $(event.target).parent().parent("tbody").length
        if @current == "top"
          @showGamesTable()
        else
          @showTopTable()
    
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