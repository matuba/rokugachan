class @TvlistingScrollManager
  scrollObj = {}
  constructor:(@window, @timeTable, @tvlistingSet) ->
    @window.bind("scroll", scroll.bind(@))
    @window.trigger("scroll")

    @timeTable.append()
    @timeTable.append()
    @timeTable.prepend()
    @timeTable.prepend()
    @tvlistingSet.setDisplayArea(timeTable.getStartTime(), timeTable.getStopTime())
    #@timeTable.append()
    @tvlistingSet.append()
    @tvlistingSet.append()
    @tvlistingSet.append()
    @tvlistingSet.append()
    @tvlistingSet.append()
    @tvlistingSet.prepend()
    @tvlistingSet.prepend()
    @tvlistingSet.prepend()
    @tvlistingSet.prepend()
    @tvlistingSet.prepend()
    ###
    @tvlistingSet.prepend()
    @timeTable.prepend()
    @tvlistingSet.prepend()
    @timeTable.prepend()
    @tvlistingSet.prepend()
    @timeTable.prepend()
    @tvlistingSet.prepend()
    ###
  init:(@window, position) ->
    @window.bind("scroll", scroll.bind(@))
    scrollBy( 0, position)

  scroll= ->
    upperSpace = $(window).scrollTop()
    lowerSpace = ($(document).height() - $(window).scrollTop())
###
    if upperSpace > (@timeTable.heightAppendUnit() * 3)
      @tvlistingSet.dropFirst()
    else if lowerSpace <= (@timeTable.heightAppendUnit() * 2)
      @tvlistingSet.append()
    if lowerSpace > (@timeTable.heightAppendUnit() * 4)
      @tvlistingSet.dropLast()
    else if upperSpace <= @timeTable.heightAppendUnit()
      @tvlistingSet.prepend()

    #Timetableの表示処理
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
