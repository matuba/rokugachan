class @TvlistingSet
  @HEIGHT_UNIT_TIME  : 300
  appendTime = 0
  prependTime = 0

  constructor:(@tvlistingsId, @tvlistingNamesId, tvlistingFileNames, nowTime, @timeInterval, startDisplay, stopDisplay) ->
    appendTime = nowTime
    prependTime = nowTime
    @tvlistings = new Array(tvlistingFileNames.length)
    for val, i in tvlistingFileNames
      @tvlistings[i] = new Tvlisting( val, @tvlistingsId, @tvlistingNamesId, nowTime, startDisplay, stopDisplay)

  append: ->
    appendTime = new Date(appendTime.getTime() + convertHourToMs(@timeInterval))
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].ajaxAppend(appendTime)

  prepend: ->
    prependTime = new Date(prependTime.getTime() - convertHourToMs(@timeInterval))
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].ajaxPrepend(prependTime)

  dropFirst : ->
    prependTime = new Date(prependTime.getTime() + convertHourToMs(@timeInterval))
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].dropFirst(prependTime)

  dropLast : ->
    appendTime = new Date(appendTime.getTime() - convertHourToMs(@timeInterval))
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].dropLast(appendTime)

  heightAppendUnit : ->
    @timeInterval * TvlistingSet.HEIGHT_UNIT_TIME

  setDisplayArea:(start, stop) ->
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].setDisplayArea(start, stop)
