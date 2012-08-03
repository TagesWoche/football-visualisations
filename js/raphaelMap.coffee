### RAPHAEL CLASS ###

class @RaphaelMap
  
  constructor: (@container, @width, @height) ->
    @map = Raphael(@container, @width, @height)

  # @param [Array] all raphaël paths that should be scaled
  # @param [Number] scale ratio
  scale: (svgs, ratio) ->
    svg.scale(ratio, ratio, 0, 0) for svg in svgs