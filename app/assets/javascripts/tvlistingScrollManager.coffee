class @TvlistingScrollManager
  scrollObj = {}
  constructor:(@window, @timeTable, @tvlistingSet) ->
    @window.bind("scroll", scroll.bind(@))
    @window.trigger("scroll")

    @timeTable.append()
    @timeTable.prepend()
    @tvlistingSet.setProgrammes(@timeTable.getStartTime(), @timeTable.getStopTime())
    scrollBy( 0, @timeTable.heightAppendUnit())

    #heightAppend = @timeTable.append()
    #@timeTable.dropFirst()
    #@tvlistingSet.setProgrammes(@timeTable.getStartTime(), @timeTable.getStopTime())
    #scrollBy( 0, -heightAppend)

  init:(@window, position) ->
    @window.bind("scroll", scroll.bind(@))
    scrollBy( 0, position)

  scroll= ->
    if @tvlistingSet.getLoadingStatus()
      return

    upperSpace = $(window).scrollTop()
    lowerSpace = ($(document).height() - $(window).scrollTop())
    heightAppend = 0
    if lowerSpace < @timeTable.heightAppendUnit()
      heightAppend = @timeTable.append()
      @timeTable.dropFirst()
      @tvlistingSet.setProgrammes(@timeTable.getStartTime(), @timeTable.getStopTime())
      scrollBy( 0, -heightAppend)

    if upperSpace < @timeTable.heightAppendUnit()
      heightAppend = @timeTable.prepend()
      @timeTable.dropLast()
      @tvlistingSet.setProgrammes(@timeTable.getStartTime(), @timeTable.getStopTime())

      scrollBy( 0, heightAppend)

###
    if lowerSpace < @timeTable.heightAppendUnit()
      start = @timeTable.getStartTime(), @timeTable.getStopTime()
      heightAppend = @timeTable.append()
      @timeTable.dropFirst()
      stop = @timeTable.getStartTime(), @timeTable.getStopTime()
      @tvlistingSet.setProgrammes(start, stop)
      scrollBy( 0, -heightAppend)

    if upperSpace < @timeTable.heightAppendUnit()
      heightAppend = @timeTable.prepend()
      @timeTable.dropLast()
      @tvlistingSet.setDisplayArea(@timeTable.getStartTime(), @timeTable.getStopTime())

      scrollBy( 0, heightAppend)
###
