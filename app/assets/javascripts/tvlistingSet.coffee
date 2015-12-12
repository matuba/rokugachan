class @TvlistingSet
  @HEIGHT_UNIT_TIME  : 300

  constructor:(@tvlistingsId, @tvlistingNamesId, tvlistingFileNames
  , @timeInterval) ->
    @tvlistings = new Array(tvlistingFileNames.length)
    for val, i in tvlistingFileNames
      @tvlistings[i] = new Tvlisting( val, @tvlistingsId, @tvlistingNamesId)

  heightAppendUnit : ->
    @timeInterval * TvlistingSet.HEIGHT_UNIT_TIME

  setProgrammes:(start, stop, displayStart, displayStop) ->
    for i in [0..@tvlistings.length-1]
      @tvlistings[i].setProgrammes(start, stop, displayStart, displayStop)

  getLoadingStatus : ->
    result = false
    for i in [0..@tvlistings.length-1]
      if @tvlistings[i].getTableStatus() == "loading"
        result = true
    return result
