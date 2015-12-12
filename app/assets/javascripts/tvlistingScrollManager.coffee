class @TvlistingScrollManager
  scrollObj = {}
  constructor:(@window, @timeTable, @tvlistingSet) ->
    @window.bind("scroll", scroll.bind(@))

    @timeTable.append()
    @timeTable.prepend()
    @tvlistingSet.setProgrammes(@timeTable.getStartTime()
    , @timeTable.getStopTime())
    scrollBy( 0, @timeTable.heightAppendUnit())

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
      @tvlistingSet.setProgrammes(@timeTable.getStartTime()
      , @timeTable.getStopTime())
      scrollBy( 0, -heightAppend)

    if upperSpace < @timeTable.heightAppendUnit()
      heightAppend = @timeTable.prepend()
      @timeTable.dropLast()
      @tvlistingSet.setProgrammes(@timeTable.getStartTime()
      , @timeTable.getStopTime())
      scrollBy( 0, heightAppend)
