@tageswoche = @tageswoche || {}

tageswoche.field = do ->

  # y offset for each scorePosition when drawing the goal arrow
  scorePosition :
    om: 40
    um: 40
    ol: 68
    ul: 68
    or: 12
    ur: 12

  # measurements from soccer field grid
  originalWidth: 1152
  widthHeightRelation: 1152 / 760

  # roughly equal widths (18 columns):
  # 1152 / 18
  cellWidth: 64

  # different row heights (11 rows):
  # rows 1-4, 8-11: 67
  # rows 5+7:       73
  # row 6:          80
  heights: [67, 67, 67, 67, 73, 80, 73, 67, 67, 67, 67]

  scale: 1
  playDirection: "left"

  # get x, y values for a position. e.g "A1" -> { x: 32, y: 33.5 }
  calcPosition: (position, mirror = false) ->
    position = @parsePosition(position, mirror)

    # calculate x and y positions
    x = (position.horizontal - 1) * @cellWidth

    y = 0
    for height, index in @heights when (index + 1) < position.vertical
      y += height

    # make adjustments so the point lies in the middle of cell
    x += @cellWidth / 2
    y += @heights[(position.vertical - 1)] / 2

    { x: @scale * x, y: @scale * y }

  calcPenaltyPosition: ->
    correction = (@scale * @cellWidth / 2)

    if @playDirection == "left"
      pos = @calcPosition("C6")
      pos.x = pos.x - correction
    else
      pos = @calcPosition("C6", true)
      pos.x = pos.x + correction

    pos


  goalPosition: ( scorePosition, xOffset, yOffset ) ->
    xOffset ?= 12
    yOffset ?= 0
    position = { horizontal: 1, vertical: 6 }

    # calculate x and y positions
    x = if @playDirection == "left" then xOffset else (@originalWidth - xOffset)

    y = @scorePosition[scorePosition]

    # reverse scorePosition if playing to the right
    y = 80 - y if @playDirection == "right"

    for height, index in @heights when (index + 1) < position.vertical
      y += height

    y = y + yOffset
    { x: @scale * x, y: @scale * y }


  # transform "B3" in { horizontal: 2, vertical: 3 }
  # optionally mirror the position ("B3" -> "Q9" -> { horizontal: 17, vertical: 9})
  parsePosition: (position, mirror = false) ->
    position = position.replace(/\s/g, "")
    positionParts = /^([a-r])([1-9][01]?)$/i.exec(position)

    if !positionParts && console
      console.log("invalid position: #{ position }")

    letter = positionParts[1]
    charCode = letter.toLowerCase().charCodeAt(0)
    horizontalPosition = charCode - 96

    verticalPositon = +positionParts[2]

    if mirror
      { horizontal: 19 - horizontalPosition, vertical: 12 - verticalPositon }
    else
      { horizontal: horizontalPosition, vertical: verticalPositon }

