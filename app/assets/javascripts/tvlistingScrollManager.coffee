class @TvlistingScrollManager
  scrollObj = {}
  constructor:(@window, @timeTable, @tvlistingSet) ->
    @window.bind("scroll", scroll.bind(@))
    @window.trigger("scroll")

    @timeTable.append()
    @timeTable.prepend()

    @tvlistingSet.append()
    @tvlistingSet.prepend()
    @tvlistingSet.setDisplayArea(@timeTable.getStartTime(), @timeTable.getStopTime())
    @tvlistingSet.removeOutSideArea()

    scrollBy( 0, @timeTable.heightAppendUnit())

  init:(@window, position) ->
    @window.bind("scroll", scroll.bind(@))
    scrollBy( 0, position)

  scroll= ->
    upperSpace = $(window).scrollTop()
    lowerSpace = ($(document).height() - $(window).scrollTop())
    heightAppend = 0

    if lowerSpace < @timeTable.heightAppendUnit()
      heightAppend = @timeTable.append()
      @timeTable.dropFirst()

      @tvlistingSet.setDisplayArea(@timeTable.getStartTime(), @timeTable.getStopTime())
      @tvlistingSet.append()

      scrollBy( 0, -heightAppend)
    if upperSpace < @timeTable.heightAppendUnit()
      heightAppend = @timeTable.prepend()
      @timeTable.dropLast()

      @tvlistingSet.setDisplayArea(@timeTable.getStartTime(), @timeTable.getStopTime())
      #@tvlistingSet.prepend()
      scrollBy( 0, heightAppend)
    @tvlistingSet.removeOutSideArea()

    ###
    if upperSpace > (@timeTable.heightAppendUnit() * 3)
      @tvlistingSet.dropFirst()
    else if lowerSpace <= (@timeTable.heightAppendUnit() * 2)
      @tvlistingSet.append()
    if lowerSpace > (@timeTable.heightAppendUnit() * 4)
      @tvlistingSet.dropLast()
    else if upperSpace <= @timeTable.heightAppendUnit()
      @tvlistingSet.prepend()

    if upperSpace > (@timeTable.heightAppendUnit() * 3)
      heightDrop = @timeTable.dropFirst()
      scrollBy( 0, -heightDrop)
    else if lowerSpace <= (@timeTable.heightAppendUnit() * 2)
      heightAppend = @timeTable.append()

    if lowerSpace > (@timeTable.heightAppendUnit() * 4)
      heightAppend = @timeTable.dropLast()
    else if upperSpace <= @timeTable.heightAppendUnit()
      heightAppend = @timeTable.prepend()
      scrollBy( 0, heightAppend)
    ###
