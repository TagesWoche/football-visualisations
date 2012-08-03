@tageswoche = @tageswoche || {}

tageswoche.curve = do ->
  percentRegex = /(\d+)%/
  
  # PUBLIC FUNCTIONS
  curve: (start, end, curvedness = 0, curvePosition = 0.5, direction) ->
    controlPoint = @bezierControlPoint(start, end, curvedness, curvePosition, direction)
    path = "M" + [start.x, start.y]
    path += "C" + [controlPoint.x, controlPoint.y, end.x, end.y, end.x, end.y]
  
  wavy: (start, end, curvedness) ->
    controlPoint1 = @bezierControlPoint(start, end, curvedness, 0.35, "right")
    controlPoint2 = @bezierControlPoint(start, end, curvedness, 0.65, "left")
    path = "M" + [start.x, start.y]
    path += "C" + [controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, end.x, end.y]
    
  arrow: (base, tip, pointyness = 0.5) ->
    size = @distance(base, tip) * pointyness
    pointA = @bezierControlPoint(base, tip, size, 0, "right")
    pointB = @bezierControlPoint(base, tip, size, 0, "left")
    path = "M" + [pointB.x, pointB.y]
    path += "L" + [tip.x, tip.y]
    path += "L" + [pointA.x, pointA.y]
  
  line: (start, end) ->
    "M" + [start.x, start.y] + "L" + [end.x, end.y]
  
  # INTERNAL FUNCTIONS
  distance: (start, end) ->
    deltaX = end.x - start.x
    deltaY = end.y - start.y
    Math.sqrt( (deltaX * deltaX) + (deltaY * deltaY) )
    
  intermediatePoint: (start, end, fraction) ->
    deltaX = end.x - start.x
    deltaY = end.y - start.y
    
    { x: start.x + ( deltaX * fraction ), y: start.y + ( deltaY * fraction ) }
  
  bezierControlPoint: (start, end, curvedness, curvePosition, direction = "right") ->
    if percent = @percent(curvedness)
      curvedness = @distance(start, end) * percent
    
    intermediatePoint = @intermediatePoint(start, end, curvePosition)
    normVector = @normVector(start, end)
    angularVector = if direction == "right"
      @rotateVectorClockwise(normVector) 
    else 
      @rotateVectorCounterClockwise(normVector)
    
    @add( intermediatePoint, @multiply(angularVector, curvedness) )
  
  # extracts
  percent: (percent) ->
    result = percentRegex.exec(percent)
    if result then ( result[1] / 100 ) else undefined
    
  multiply: (vector, multiplicator) ->
    { x: ( vector.x * multiplicator ), y: ( vector.y * multiplicator ) }
    
  add: (vector1, vector2) ->
    { x: ( vector1.x + vector2.x ), y: ( vector1.y + vector2.y ) }
    
  normVector: (start, end) ->
    deltaX = (end.x - start.x)
    deltaY = (end.y - start.y)
    distance = Math.sqrt( (deltaX * deltaX) + (deltaY * deltaY) )
    normX = deltaX / distance
    normY = deltaY / distance
    { x: normX, y: normY }
    
  # 90° clockwise
  rotateVectorClockwise: (vector) ->
    { x: vector.y, y: -vector.x }
  
  # 90° counter-clockwise
  rotateVectorCounterClockwise: (vector) ->
    { x: -vector.y, y: vector.x }
    
  delta: (start, end) ->
    { x: (end.x - start.x), y: (end.y - start.y) }
    
  slope: (start, end) ->
    delta = @delta(start, end)
    
    delta.y / delta.x
    
  inverseSlope: (start, end) ->
    -1 / @slope(start, end)