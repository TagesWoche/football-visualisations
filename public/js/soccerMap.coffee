### SOCCERMAP CLASS ###
class @SoccerMap extends RaphaelMap
  curve = tageswoche.curve
  field = tageswoche.field
  data = tageswoche.data
  
  constructor: (container, width, @settings = {}) ->
    self = this
    field.scale = width / field.originalWidth
    height = width / field.widthHeightRelation
    super(container, width, height)
    
    @scene = undefined
    @actions = []
    
    @black = "#555555"
    @red = "#EE402F"
    @blue = "#0051A3"
    @white = "#FFFFFF"
    @circleRadius = 13
    @playerColor = @red
    
    @pathAttributes =
      default:
        fill: @playerColor
        stroke: ""
        "stroke-width": 1.0
        "stroke-linejoin": "round"
    
    @initEvents()  
    @nextScene()
  
  nextScene: () ->
    data.loadScenes (error, scenes) =>
      @scene = data.nextScene()
      @draw()
  
  previousScene: () ->
    data.loadScenes (error, scenes) =>
      @scene = data.previousScene()
      @draw()
  
  initEvents: () ->
    $("#next-scene").click =>
      event.preventDefault()
      @nextScene()
    
    $("#prev-scene").click =>
      event.preventDefault()
      @previousScene()
    
    $("#scene-list").on "click", "a", (event) =>
      event.preventDefault();
      $this = $(event.target)
      sceneIndex = $this.parent().data("sceneIndex")
      scene = data.scenes[sceneIndex]
      @scene = data.getScene(sceneIndex)
      @draw()
    
  draw: ->
    if @scene.team.toLowerCase() == "fcb" 
      field.playDirection = "left" 
      @playerColor = @red
      @pathAttributes.default.fill = @playerColor
    else 
      field.playDirection = "right"
      @playerColor = @black
      @pathAttributes.default.fill = @playerColor
    
    @actions = @scene.actions
    
    # prepare the positions
    for action in @actions
      first = action.positions[0]
      last = if action.positions.length > 1 then action.positions[( action.positions.length - 1)] else undefined
      action.start = field.calcPosition(first)
      action.end = field.calcPosition(last) if last
    
    # draw visualization elements
    @map.clear()
    @updateInfo()
    @drawPasses()
    @drawPositions()
  
  updateInfo: ->
    $("#result .score").html(@scene.score)
    $("#result .left").html("FCB")
    $("#result .right").html(@scene.opponent.toUpperCase()) if @scene.opponent
    
    game = data.games[@scene.date]
    ul = $("#scene-list").html("")
    for sceneIndex in game
      scene = data.scenes[sceneIndex]
      $gameLink = $("<li><a href='' class='#{ "active" if scene == @scene }'>#{ scene.minute }.</a></li>")
      $gameLink.data("sceneIndex", sceneIndex)
      ul.append($gameLink)
    
  drawPasses: ->
    lastPosition = undefined
    for action in @actions
      if action.end
        @drawSprint(action.start, action.end)
        
      if lastPosition
        @addPass(lastPosition, action.start)
        
      lastPosition = if action.end then action.end else action.start
    
    # draw goal
    if lastPosition
      @drawGoal(lastPosition)
    
  drawPositions: ->
    for action in @actions
      startCircleRadius = @circleRadius
      drawStartLabel = true
      
      if action.end
        @map.circle(action.end.x, action.end.y, @circleRadius).attr(@pathAttributes.default)
        @label(action.end, action.number) if action.number
        startCircleRadius = startCircleRadius / 2
        drawStartLabel = false
        
      @map.circle(action.start.x, action.start.y, startCircleRadius).attr(@pathAttributes.default)
      @label(action.start, action.number) if drawStartLabel && action.number
  
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
    color = "#FFFFFF"

    x = position.x
    if +label > 9
      x -= 1
      
    font = '200 16px "Helvetica Neue", Helvetica, "Arial Unicode MS", Arial, sans-serif';
    @map.text(x, position.y, label).attr({fill: color, stroke: "none", "font": font})
    
    