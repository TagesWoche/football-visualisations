### SOCCERMAP CLASS ###
class @SoccerMap extends RaphaelMap
  curve = tageswoche.curve
  field = tageswoche.field
  data = tageswoche.data

  constructor: (@container, @settings = {}) ->
    self = this
    width = $("#scenes").width()
    field.scale = width / field.originalWidth
    height = width / field.widthHeightRelation
    super(@container, width, height)

    @scene = undefined
    @actions = []

    # Colors
    @black = "#555555"
    @red = "#EE402F"
    @blue = "#0051A3"
    @white = "#FFFFFF"
    @darkGrey = "#333333"

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
    @shadowOpacity = 0.5

    # initialize
    @initEvents()
    @firstScene()

    # listen to resize events
    $(window).resize (event) =>
      @redrawField()

  redrawField: () ->
    width = $("#scenes").width()
    field.scale = width / field.originalWidth
    height = width / field.widthHeightRelation

    # resize current map
    @map.setSize(width, height)

    # create new one
    @draw()

  firstScene: () ->
    data.loadScenes (error, scenes) =>
      if startDate = data.getStartDate()
        @scene = data.findScene(startDate)

      @scene ||= data.firstScene()

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
    $("#next-scene").click (event) =>
      event.preventDefault()
      @nextScene()

    $("#prev-scene").click (event) =>
      event.preventDefault()
      @previousScene()

    $("#prev-game").click (event) =>
      event.preventDefault()
      @previousGame()

    $("#next-game").click (event) =>
      event.preventDefault()
      @nextGame()

    $("#scene-list").on "click", "a", (event) =>
      event.preventDefault();
      $this = $(event.target)
      sceneIndex = $this.parent().data("sceneIndex")
      scene = data.scenes[sceneIndex]
      @scene = data.gotoScene(sceneIndex)
      @draw()

  fcbScene: ->
    @scene.team.toLowerCase() == "fcb"

  draw: ->
    if @fcbScene()
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
    #console.log(@scene.score)
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

        # attribute assist if it makes sense
        if length > 1
          assistAction = @actions[length - 2]
          if !assistAction.foul && !@otherTeamAction(assistAction)
            @scene.assist = assistAction.name
            if assistAction.directFreeKick
              @scene.assist = "#{ @scene.assist } (Freistoss direkt)"
            else if assistAction.indirectFreeKick
              @scene.assist = "#{ @scene.assist } (Freistoss indirekt)"

  # determine if the action is from a player from the opposing team
  # if an action has a player number its an fcb action
  otherTeamAction: (action) ->
    if @fcbScene()
      !action.number
    else
      !!action.number

  sceneInfo: ->
    @extractSceneInfo()

    desc = $("#scene-desc").html("")
    .append("<em>#{ @scene.team} &ndash; #{ @scene.minute}. Minute:</em>")
    .append("<span>Tor: <strong>#{ @scene.goal }</strong></span>")

    if @scene.assist
      desc.append("<span>Assist: <strong>#{ @scene.assist }</strong></span>")

  setupPopups: ->
    $(".player-number").hover (event) =>
      $elem = $(event.currentTarget)
      $($elem.prev()).tooltip("show")
    , (event) =>
      $elem = $(event.currentTarget)
      $($elem.prev()).tooltip("hide")
    # $(".player, .player-number").hover( (event) =>
    #   $elem = $(event.currentTarget)
    #   playerStatistics = tageswoche.tableData.getStatisticsForPopup()
    #   playerStats = _.find(playerStatistics.list, (player) ->
    #     player.nickname == $elem.attr("data-playername")
    #   )
    #   @showPopup(playerStats, $elem)
    # , (event) =>
    #   $elem = $(event.currentTarget)
    #   if $elem.attr("class") == "player-number"
    #     false
    #     #console.log($elem)
    #     #$elem.tooltip("hide")
    #   if $elem.attr("class") == "player"
    #     false
    #     #console.log($elem)
    #     #$($elem.prev()).tooltip("hide")
    #   #console.log("hover out")
    # )
    $(".player, .player-number").tooltip()

  showPopup: (playerStats, $elem) ->
    #if !@popupVisible
    #console.log($elem.attr("class"))
    if $elem.attr("class") == "player"
      #console.log($($elem.next()))
      $($elem.next()).tooltip( { title: playerStats.name } )
      $($elem.next()).tooltip("show")
    else if $elem.attr("class") == "player-number"
      $elem.tooltip( { title: playerStats.name } )
      #@popupVisible = true

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

      # mark standards
      if action.penalty || action.directFreeKick || action.indirectFreeKick
        currentAttributes = $.extend({}, currentAttributes, { stroke: @white })

      # player position
      circle = @map.circle(player.x, player.y, @circleRadius).attr(currentAttributes)
      $circle = jQuery(circle.node)
      $circle.attr("title", action.fullname || action.name)
      @label {player, action}


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

    # reverse foot depending on playDirection (so the ball flies towards the goal which looks more natural)
    if field.playDirection == "right"
      foot = if foot == "left" then "right" else "left"

    # shadow (to discern high and low kicks)
    xCorrection = if field.playDirection == "right" then -5 else 5
    yCorrection = if @scene.highKick then 14 else 3
    endShadowX = end.x + (xCorrection * field.scale)
    endShadowY = end.y + (yCorrection * field.scale)
    path = curve.curve(start, { x: endShadowX, y: endShadowY }, "8%", 0.6, foot)
    @drawArrow(path, { size: 10, pointyness: 0.3, strokeWidth: 3, color: @darkGrey, opacity: @shadowOpacity })
    @map.path(path).attr({ fill:"", stroke:  @darkGrey, "stroke-width": 3, opacity: @shadowOpacity })

    # shoot
    path = curve.curve(start, end, "8%", 0.6, foot)
    @drawArrow(path, { size: 10, pointyness: 0.3, strokeWidth: 3 })
    @map.path(path).attr({ fill:"", stroke: @white, "stroke-width": 3 })


  drawArrow: (path, { length, size, pointyness, strokeWidth, color, opacity }) ->
    length ?= Raphael.getTotalLength(path)
    size ?= 10
    pointyness ?= 0.3
    strokeWidth ?= 2
    color ?= @white
    opacity ?= 1

    # only draw arrowhead if the length of the path is sufficient
    if (length - size) > 5
      base = Raphael.getPointAtLength(path, length - size)
      tip = Raphael.getPointAtLength(path, length)
      arrowhead = curve.arrow(base, tip, pointyness)

      @map.path(arrowhead).attr({ fill:"", stroke: color, "stroke-width": strokeWidth, opacity: opacity })


  label: ({player, action}) ->
    x = player.x

    # Basel's player
    if action.number?
      # small text placement correction for 10 and upwards...
      if +action.number > 9 && +action.number < 20
        x -= 1

      text = @map.text(x, player.y, action.number).attr(@numberTextAttributes)
    else
      # this is a hack to write with the bg color
      text = @map.text(player.x, player.y, 0).attr(@opponentAttributes)

    # popover text
    $text = jQuery(text.node)
    $text.attr("rel", "tooltip").attr("class", "player-number").attr("data-playername", action.fullname || action.name)



