@tageswoche = @tageswoche || {}

tageswoche.field = do ->

  # measurements from soccer field grid
  originalWidth = 1152
  widthHeightRelation = 1152 / 760

  # roughly equal widths (18 columns):
  # 1152 / 18
  cellWidth = 64

  # different row heights (11 rows):
  # rows 1-4, 8-11: 67
  # rows 5+7:       73
  # row 6:          80
  heights = [67, 67, 67, 67, 73, 80, 73, 67, 67, 67, 67]

  scale: 1
  
  # Setup
  setup: (container, width) ->
    @scale = width / originalWidth
    height = width / widthHeightRelation
    map = new SoccerMap(container, width, height)
    
    sceneArray = tageswoche.data.nextScene()
    for scene in sceneArray
      scene.start = @calcPosition(scene.start)
      scene.end = @calcPosition(scene.end) if scene.end
      map.addScene(scene)
    
    map.draw()
    
  # get x, y values for a position. e.g "A1" -> { x: 32, y: 33.5 }
  calcPosition: (position, mirror = false) ->
    position = @parsePosition(position, mirror)
  
    # calculate x and y positions
    x = (position.horizontal - 1) * cellWidth
  
    y = 0
    for height, index in heights when (index + 1) < position.vertical
      y += height
  
    # make adjustments so the point lies in the middle of cell
    x += cellWidth / 2
    y += heights[(position.vertical - 1)] / 2
  
    { x: @scale * x, y: @scale * y }

  # transform "B3" in { horizontal: 2, vertical: 3 }
  # optionally mirror the position ("B3" -> "Q9" -> { horizontal: 17, vertical: 9})
  parsePosition: (position, mirror = false) ->
    position = position.trim()
    letter = position.charAt(0)

    charCode = letter.toLowerCase().charCodeAt(0)
    horizontalPosition = charCode - 96
  
    verticalPositon = position.charAt(1)
    
    if mirror
      { horizontal: 19 - horizontalPosition, vertical: 12 - verticalPositon }
    else
      { horizontal: horizontalPosition, vertical: verticalPositon }

