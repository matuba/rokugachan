class @TvlistingSet
  @HEIGHT_UNIT_TIME  : 300

  constructor:(@tvlistingsId, @tvlistingNamesId, tvlistingFileNames, @nowTime, @timeInterval) ->
    @tvlistings = new Array(tvlistingFileNames.length)
    for val, i in tvlistingFileNames
      @tvlistings[i] = new Tvlisting( val, @tvlistingsId, @tvlistingNamesId, @nowTime)

  append: ->
    @nowTime = new Date(@nowTime.getTime() + (1000 * 60 * 60 * @timeInterval))
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].ajaxAppend(@nowTime)

  prepend: ->
    @nowTime = new Date(@nowTime.getTime() - (1000 * 60 * 60 * @timeInterval))
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].ajaxPrepend(@nowTime)

  dropFirst : ->
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].dropFirst(@nowTime)

  dropLast : ->
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].dropLast(@nowTime)

  heightAppendUnit : ->
    @timeInterval * TvlistingSet.HEIGHT_UNIT_TIME
