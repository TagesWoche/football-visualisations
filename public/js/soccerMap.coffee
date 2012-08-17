### SOCCERMAP CLASS ###
class @SoccerMap extends RaphaelMap
  curve = tageswoche.curve
  field = tageswoche.field
  data = tageswoche.data
  
  constructor: (container, @settings = {}) ->
    self = this
    width = $("#scenes").width();
    field.scale = width / field.originalWidth
    height = width / field.widthHeightRelation
    super(container, width, height)
    
    @scene = undefined
    @actions = []
    
    # Colors
    @black = "#555555"
    @red = "#EE402F"
    @blue = "#0051A3"
    @white = "#FFFFFF"
    
    # Attributes
    @fcbAttributes =
      fill: @red
      stroke: ""
      "stroke-width": 1.0
      "stroke-linejoin": "round"
      
    @opponentAttributes =
      fill: @black
      stroke: ""
      "stroke-width": 1.0
      "stroke-linejoin": "round"
    
    @numberTextAttributes = 
      fill: "#FFFFFF"
      stroke: "none"
      font: '200 13px "Helvetica Neue", Helvetica, "Arial Unicode MS", Arial, sans-serif'
      
    # other Settings
    @circleRadius = 11
    @playerColor = @red
    @playerAttributes = @fcbAttributes
    
    # initialize
    @initEvents()  
    @firstScene()

  firstScene: () ->
    data.loadScenes (error, scenes) =>
      @scene = data.firstScene()
      @draw()
      
  nextScene: () ->
    @scene = data.nextScene()
    @draw()
  
  previousScene: () ->
    @scene = data.previousScene()
    @draw()
    
  nextGame: () ->
    if next = data.nextGameScene()
      @scene = data.gotoScene(next.index)
      @draw()
  
  previousGame: () ->
    if prev = data.previousGameScene()
      @scene = data.gotoScene(prev.index)
      @draw()
  
  initEvents: () ->
    $("#next-scene").click =>
      event.preventDefault()
      @nextScene()
    
    $("#prev-scene").click =>
      event.preventDefault()
      @previousScene()
    
    $("#prev-game").click =>
      event.preventDefault()
      @previousGame()
        
    $("#next-game").click =>
      event.preventDefault()
      @nextGame()
        
    $("#scene-list").on "click", "a", (event) =>
      event.preventDefault();
      $this = $(event.target)
      sceneIndex = $this.parent().data("sceneIndex")
      scene = data.scenes[sceneIndex]
      @scene = data.gotoScene(sceneIndex)
      @draw()      

  draw: ->
    if @scene.team.toLowerCase() == "fcb" 
      field.playDirection = "left" 
      @playerColor = @red
      @playerAttributes = @fcbAttributes
    else 
      field.playDirection = "right"
      @playerColor = @black
      @playerAttributes = @opponentAttributes
    
    @actions = @scene.actions
    
    # prepare the positions
    for action in @actions
      first = action.positions[0]
      last = action.positions[( action.positions.length - 1)]
      
      if action.positions.length > 1
        action.running = true
        
      action.start = field.calcPosition(first)
      action.end = if action.running then field.calcPosition(last) else action.start
        
      if action.penalty
        action.end = field.calcPenaltyPosition()
    
    # draw visualization elements
    @map.clear()
    @drawPasses()
    @drawPositions()
    @updateInfo()
    @sceneInfo()

    @setupPopups()
  
  updateInfo: ->
    $("#scene-result .score").html(@scene.score)
    $("#scene-result .left span").html("FCB")
    $("#scene-result .right span").html(@scene.opponent.toUpperCase()) if @scene.opponent
    
    # update navigation
    $("#prev-scene, #next-scene, #prev-game, #next-game").css("visibility", "visible")
    if data.isLastScene() then $("#next-scene").css("visibility", "hidden")
    if data.isFirstScene() then $("#prev-scene").css("visibility", "hidden")
    if !data.nextGameScene() then $("#next-game").css("visibility", "hidden")
    if !data.previousGameScene() then $("#prev-game").css("visibility", "hidden")
    
    game = data.games[@scene.date]
    ul = $("#scene-list").html("")
    for sceneIndex in game
      scene = data.scenes[sceneIndex]
      $gameLink = $("<li><a href='' class='#{ "active" if scene == @scene }'>#{ scene.minute }.</a></li>")
      $gameLink.data("sceneIndex", sceneIndex)
      ul.append($gameLink)
  
  extractSceneInfo: ->
    length = @actions.length
    if length
      goalAction = @actions[length - 1]
      if !goalAction.foul
        @scene.goal = goalAction.name
        if goalAction.penalty
          @scene.goal = "#{ @scene.goal } (Penalty)"
        else if goalAction.directFreeKick
          @scene.goal = "#{ @scene.goal } (Freistoss direkt)"
        else if goalAction.indirectFreeKick
          @scene.goal = "#{ @scene.goal } (Freistoss indirekt)"
        
        if length > 1
          assistAction = @actions[length - 2]
          if !assistAction.foul && !assistAction.number
            @scene.assist = assistAction.name
    
  sceneInfo: ->
    @extractSceneInfo()
    
    desc = $("#scene-desc").html("")
    .append("<em>#{ @scene.team} &ndash; #{ @scene.minute}. Minute:</em>")
    .append("<span>Tor: <strong>#{ @scene.goal }</strong></span>")
    
    if @scene.assist
      desc.append("<span>Assist: <strong>#{ @scene.assist }</strong></span>")
       
  setupPopups: ->
    $(".player").hover (event) ->
      $this = $(@)
      playerStatistics = tageswoche.tableData.getStatisticsForPopup()
      playerStats = _.find(playerStatistics.list, (player) ->
        player.nickname == $this.attr("data-playername")
      )
      # TODO: draw the popup
       
  drawPasses: ->
    lastPosition = undefined
    for action in @actions
      if action.running
        @drawSprint(action.start, action.end)
        
      if lastPosition
        @addPass(lastPosition, action.start)
      
      if action.foul
        # don't draw a pass from a foul position to the next one
        lastPosition = undefined
      else
        lastPosition = action.end
    
    # draw goal
    if lastPosition
      @drawGoal(lastPosition)
      
    
  drawPositions: ->
    for action in @actions

      # hack: show all players with numbers as fcb Players 
      # ...this only makes a difference in scenes of the opponent
      currentAttributes = if action.number then @fcbAttributes else @playerAttributes
      
      start = action.start 
      player = action.end
        
      # draw start position (only for running players)
      if action.running
        @map.circle( start.x, start.y, (@circleRadius * 0.5) ).attr(currentAttributes)
        # @label(start, action.number) if action.number
        
      # player position
      if action.penalty
        currentAttributes = $.extend({}, currentAttributes, { stroke: @white })
        
      circle = @map.circle(player.x, player.y, @circleRadius).attr(currentAttributes)
      $circle = jQuery(circle.node)
      $circle.attr("data-playername", action.name)
      $circle.attr("class", "player")
      @label(player, action.number) if action.number
        
  
  drawSprint: (start, end) ->
    # path = curve.line(start, end)
    path = curve.wavy(start, end, "10%")
    @map.path(path).attr({ fill:"", stroke: @playerColor, "stroke-width": 2 })
               
  addPass: (start, end) ->
    path = curve.curve(start, end, "10%", 0.6, "right")
    startGap = 0
    endGap = 16
    length = Raphael.getTotalLength(path)
    subCurve = Raphael.getSubpath(path, startGap, (length - endGap) )
    @drawArrow(path, { length: (length - endGap) })
    
    @map.path(subCurve).attr({ fill:"", stroke: @white, "stroke-width": 2 })
    
  drawGoal: (start) ->
    end = field.goalPosition( @scene.scorePosition.toLowerCase() )
    foot = if start.y < end.y then "left" else "right"
    
    # reverse foot depending on playDirection
    if field.playDirection == "right"
      foot = if foot == "left" then "right" else "left"
    
    path = curve.curve(start, end, "10%", 0.6, foot)
    @drawArrow(path, { size: 10, pointyness: 0.3, strokeWidth: 3 })
    @map.path(path).attr({ fill:"", stroke: @white, "stroke-width": 3 })
    
  drawArrow: (path, { length, size, pointyness, strokeWidth, color }) ->
    length ?= Raphael.getTotalLength(path)
    size ?= 10
    pointyness ?= 0.3
    strokeWidth ?= 2
    color ?= @white
    
    # only draw arrowhead if the length of the path is sufficient
    if (length - size) > 5
      base = Raphael.getPointAtLength(path, length - size)
      tip = Raphael.getPointAtLength(path, length)
      arrowhead = curve.arrow(base, tip, pointyness)
      
      @map.path(arrowhead).attr({ fill:"", stroke: color, "stroke-width": strokeWidth })
      
    
  label: (position, label) ->
    
    # small text placement correction for 10 and upwards...
    x = position.x
    if +label > 9 && +label < 20
      x -= 1
      
    @map.text(x, position.y, label).attr(@numberTextAttributes)
    
    