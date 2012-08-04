### NATIONALRAT CLASS ###
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
    
    @red = "#EE402F"
    @blue = "#0051A3"
    @white = "#FFFFFF"
    @circleRadius = 13
    
    @pathAttributes =
      default:
        fill: @red #E1E0DD #EFEFEA #c7c7c7
        stroke: ""
        "stroke-width": 1.0
        "stroke-linejoin": "round"
        
    @nextScene()
  
  nextScene: () ->
    data.loadScenes (error, scenes) =>
      @scene = data.nextScene()
      @draw()
  
  previousScene: () ->
    data.loadScenes (error, scenes) =>
      @scene = data.previousScene()
      @draw()
  
  draw: ->
    @actions = @scene.actions
    
    # prepare the positions
    for action in @actions
      action.start = field.calcPosition(action.start)
      action.end = field.calcPosition(action.end) if action.end
    
    # draw visualization elements
    @map.clear()
    @updateInfo()
    @drawPasses()
    @drawPositions()
  
  updateInfo: ->
    $("#result .score").html(@scene.score)
    
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
        @label(action.end, action.number)
        startCircleRadius = startCircleRadius / 2
        drawStartLabel = false
        
      @map.circle(action.start.x, action.start.y, startCircleRadius).attr(@pathAttributes.default)
      @label(action.start, action.number) if drawStartLabel
  
  drawSprint: (start, end) ->
    # path = curve.line(start, end)
    path = curve.wavy(start, end, "10%")
    @map.path(path).attr({ fill:"", stroke: @red, "stroke-width": 2 })
               
  addPass: (start, end) ->
    path = curve.curve(start, end, "10%", 0.6, "right")
    startGap = 0
    endGap = 16
    length = Raphael.getTotalLength(path)
    subCurve = Raphael.getSubpath(path, startGap, (length - endGap) )
    @drawArrow(path, { length: (length - endGap) })
    
    @map.path(subCurve).attr({ fill:"", stroke: @white, "stroke-width": 2 })
    
  drawGoal: (start) ->
    end = field.goalPosition()
    path = curve.curve(start, end, "10%", 0.6, "right")
    @drawArrow(path, { size: 10, pointyness: 0.3, strokeWidth: 3 })
    @map.path(path).attr({ fill:"", stroke: @white, "stroke-width": 3 })
    
  drawArrow: (path, { length, size, pointyness, strokeWidth, color }) ->
    length ?= Raphael.getTotalLength(path)
    size ?= 10
    pointyness ?= 0.3
    strokeWidth ?= 2
    color ?= @white
    
    # only draw arrowhead if the length of the path is sufficient
    if (length - size) > 30
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
    
    