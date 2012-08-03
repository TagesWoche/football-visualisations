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
    
    @scenes = []
    
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
        
    @setup()
  
  # Setup
  setup: (container, width) ->

    data.loadScenes (error, scenes) =>
      scene = data.nextScene()
      for action in scene.actions
        action.start = field.calcPosition(action.start)
        action.end = field.calcPosition(action.end) if action.end
        @addScene(action)

      @draw()
          
  addScene: (scene) ->
    @scenes.push( scene ) 
  
  draw: ->
    @drawPasses()
    @drawPositions()
      
  drawPasses: ->
    lastPosition = undefined
    for scene in @scenes
      if scene.end
        @drawSprint(scene.start, scene.end)
        
      if lastPosition
        @addPass(lastPosition, scene.start)
        
      lastPosition = if scene.end then scene.end else scene.start
    
  drawPositions: ->
    for scene in @scenes
      startCircleRadius = @circleRadius
      drawStartLabel = true
      
      if scene.end
        @map.circle(scene.end.x, scene.end.y, @circleRadius).attr(@pathAttributes.default)
        @label(scene.end, scene.number)
        startCircleRadius = startCircleRadius / 2
        drawStartLabel = false
        
      @map.circle(scene.start.x, scene.start.y, startCircleRadius).attr(@pathAttributes.default)
      @label(scene.start, scene.number) if drawStartLabel
  
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
    @drawArrow(path, (length - endGap))
    
    @map.path(subCurve).attr({ fill:"", stroke: @white, "stroke-width": 2 })
    
  
  drawArrow: (path, endLength) ->
    arrowSize = 10
    
    # only draw arrowhead if the length of the path is sufficient
    if (endLength - arrowSize) > 30
      base = Raphael.getPointAtLength(path, endLength - arrowSize)
      tip = Raphael.getPointAtLength(path, endLength)
      arrowhead = curve.arrow(base, tip, 0.3)
      
      @map.path(arrowhead).attr({ fill:"", stroke: @white, "stroke-width": 2 })
      
    
  label: (position, label) ->
    color = "#FFFFFF"

    x = position.x
    if +label > 9
      x -= 1
      
    font = '200 16px "Helvetica Neue", Helvetica, "Arial Unicode MS", Arial, sans-serif';
    @map.text(x, position.y, label).attr({fill: color, stroke: "none", "font": font})
    
    