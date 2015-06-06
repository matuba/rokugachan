class @TvlistingSet
  @tvlistings:null
  constructor:(@window, @tvlistingsId, @tvlistingNamesId, @nowTime) ->
    @timetable = new TimeTable("timetable", @tvlistingsId, @nowTime)
    TvlistingSet.tvlistings = new Array(9)
    TvlistingSet.tvlistings[0] = new Tvlisting( "test1", @tvlistingsId, @tvlistingNamesId, @nowTime)
    TvlistingSet.tvlistings[1] = new Tvlisting( "test2", @tvlistingsId, @tvlistingNamesId, @nowTime)
    @window.bind("scroll", @scroll)

  scroll : ->
    @nowTime = new Date(@nowTime.getTime() + (1000 * 60 * 60 * 4))
    TvlistingSet.tvlistings[0].ajaxAppendListingTable(@nowTime)
