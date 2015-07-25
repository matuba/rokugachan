class @Tvlisting

  @TIME_RANGE : (60 * 4)
  @ONE_MINUTE_HEIGHT: 5
  @TITLE_LINE_LENGTH: 12
  @DAY_OF_WEEK = ["日", "月", "火", "水", "木", "金", "土"]

  constructor:(@channelname, tvlistingsId, tvlistingNamesId, @createtime) ->
    @tvlistingNameTable = @createListingNameTable(tvlistingNamesId, @channelname)
    @tvlistingsTable = @createListingTable(tvlistingsId, @channelname, @createtime)
    #常に１番最初のプログラムとしておいておく、高さの調整で使う
    @firstProgramme =  @tvlistingsTable.children('tbody').children('tr:first')

    @ajaxSetChannelName()
    @ajaxAppend(createtime)

  createListingNameTable:(tvlistingNamesId, channelname) ->
    tvlistingNameTable = $("<table id='" + channelname + "'></table>").appendTo("#" + tvlistingNamesId)
    tvlistingNameTable.addClass("table table-bordered table-condensed channelname")
    tvlistingNameTable.append("<tr><td></td></tr>")

  createListingTable:(tvlistingsId, channelname, createtime) ->
    tvlistingsTable = $("<table id='" + channelname + "' />").appendTo("#" + tvlistingsId)
    tvlistingsTable.addClass("table table-bordered table-condensed tvlisting")
    tvlistingsTable.attr({"now":createtime.getTime()});
    tvlistingsTable.css("width", "140px")
    tvlistingsTable.css("float", "left")
    trFirst = $('<tr/>')
    trFirst.attr({"id":"first"})
    trFirst.attr({"stop":createtime.getTime()})
    trFirst.css("height", "0px")
    tvlistingsTable.append(trFirst)

  @calcProgrammeHeight:( start, stop) ->
    return (( stop - start) / (1000 * 60)) * @ONE_MINUTE_HEIGHT;

  @createSpaceTag:( start, stop) ->
    height = @calcProgrammeHeight( start, stop)
    if height is 0
      return
    tr = $('<tr/>')
    tr.attr({"start":start})
    tr.attr({"stop":stop})
    tr.css("height", height + "px")
    return tr

  @adjustProgrammeTitle:(title, height) ->
    adjustTitle = title
    if height <= @ONE_MINUTE_HEIGHT * 3
      adjustTitle = title.substring(0, @TITLE_LINE_LENGTH)
    else if height <= @ONE_MINUTE_HEIGHT * 5
      adjustTitle = title.substring(0, @TITLE_LINE_LENGTH * 2)
    else if height <= @ONE_MINUTE_HEIGHT * 7
      adjustTitle = title.substring(0, @TITLE_LINE_LENGTH * 3)

    if adjustTitle.lngth != title.length
      adjustTitle = adjustTitle + "..."
    return adjustTitle

  @adjustProgrammeFontSize:(height) ->
    if height <= @ONE_MINUTE_HEIGHT
      return 5
    return 10

  @createProgrammeTag:( programme) ->
    height = @calcProgrammeHeight( programme.start, programme.stop)
    start = new Date(programme.start)
    stop = new Date(programme.stop)
    infoTime = (" "+start.getDate()).slice(-2) + "日(" + @DAY_OF_WEEK[start.getDay()] + ")"
    infoTime = infoTime + ("0"+start.getHours()).slice(-2) + ":" + ("0"+start.getMinutes()).slice(-2)
    infoTime = infoTime + "-" + ("0"+stop.getHours()).slice(-2) + ":" + ("0"+stop.getMinutes()).slice(-2)

    tr = $('<tr/>')
    tr.attr({"class":"tvlisting"})
    tr.attr({"start":programme.start})
    tr.attr({"stop":programme.stop})
    tr.css("height", height.toString() + "px")
    tr.hover ->
      $('#infoTime').html("<font color='lightcyan'>" + infoTime + "</font>")
      $('.marquee').html("<font color='lightcyan'>" + programme.title + "</font>" + programme.desc)
      $('.marquee').marquee({
        speed: 10000,
        gap: 150,
        delayBeforeStart: 900,
        direction: 'left',
        duplicated: true,
        pauseOnHover: true
      });

    value = "<td class='" + programme.category + "'>"
    value = value + "<div class='tvlisting'"
    value = value + "style='height: " + height + "px; "
    value = value + "font-size: " + @adjustProgrammeFontSize( height) + "px;' "
    value = value + ">"
    value = value + @adjustProgrammeTitle(programme.title, height)
    value = value + "</div>"
    value = value + "</td>"
    tr.html(value)

    return tr

  @adjustFirstHeight:(table) ->
    firstBuffer = table.children('tbody').children('tr#first')
    firstProgramme = firstBuffer.next()
    start = new Date(parseInt(firstProgramme.attr("start"),10))
    stop = new Date(parseInt(firstProgramme.attr("start"),10))
    start.setMinutes(0)
    height = @calcProgrammeHeight(start, stop)
    firstBuffer.css("height", height + "px")

  ajaxSetChannelName : ->
    url = getJsonChannelNameURL(@channelname)
    jQuery.ajaxQueue( {url:url, success:(channelName) => @tvlistingNameTable.children('tbody').children('tr').children('td').text(channelName)});

  createProgrammesUnitTag :(programmes) ->
    spaceStart = programmes[0].start
    result = []
    for programme in programmes
      result = result + @createProgrammeTag(programme)







  @createProgrammeTagArray:(programmes, table) ->
    if programmes.length is 0
      return
    trLast = table.children('tbody').children('tr:last')
    spaceStart = Number(trLast.attr("stop"))
    #番組との間に番組がない場合スペースを挿入する
    index = 0
    resultProgrammes = []
    for programme in programmes
      spaceStop = programme.start
      if spaceStart < spaceStop
        resultProgrammes[index] = @createSpaceTag(spaceStart, spaceStop)
        index++
      resultProgrammes[index] = @createProgrammeTag(programme)
      index++
      spaceStart = programme.stop
    return resultProgrammes

  @appendTrCallBack:(programmes, table) ->
    if programmes.length is 0
      return
    appendStart = table.attr("now")
    appendStop = appendStart + (Tvlisting.TIME_RANGE * 60 * 1000)
    insertProgrammes = @createProgrammeTagArray(programmes, table)
    
    mergeFirstProgramme
    mergeLastProgramme

    for programme in insertProgrammes
      if programme.attr("stop") < appendStart
        continue
      if programme.attr("start") > appendStop
        continue
      start =
      if programme.attr("start") < appendStart
        programme.css("height", @calcProgrammeHeight( programme.start, programme.stop) + "px")



    ###
    if programmes.length is 0
      table.attr({"loading":false});
      return
    trLast = table.children('tbody').children('tr:last')
    if trLast.attr("id") == "first"
      spaceStart = programmes[0].start
    else
      spaceStart = Number(trLast.attr("stop"))

    for programme in programmes
      spaceStop = programme.start
      if spaceStart != spaceStop
        table.append(@createSpaceTag(spaceStart, spaceStop))
      table.append(@createProgrammeTag(programme))
      spaceStart = programme.stop
    ###

  ajaxAppend:(nowTime, timerange=Tvlisting.TIME_RANGE) ->
    url = getJsonProgrammesURL(nowTime, timerange, "GR", @channelname)
    @tvlistingsTable.attr({"now":nowTime.getTime()});
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.appendTrCallBack( programmes, @tvlistingsTable)
    complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable)
    })


  @prependTrCallBack:(programmes, table) ->
    if programmes.length is 0
      table.attr({"loading":false});
      return
    lastIndex = programmes.length - 1
    trFirst = table.children('tbody').children('tr#first').next()
    spaceStop = Number(trFirst.attr("start"))

    for programme, i in programmes by -1
      spaceStart = programme.stop
      if spaceStart != spaceStop
        trFirst.before(@createSpaceTag(spaceStart, spaceStop))
        trFirst = trFirst.prev()
      trFirst.before(@createProgrammeTag(programme))
      trFirst = trFirst.prev()

      spaceStop = programme.start

  ajaxPrepend:(createtime, timerange=Tvlisting.TIME_RANGE) ->
    url = getJsonProgrammesURL(createtime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.prependTrCallBack( programmes, @tvlistingsTable, createtime)
    complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable, createtime)
    })

  dropFirst:() ->

    Tvlisting.adjustFirstHeight(@tvlistingsTable)










  appendTr:(appendTime, timerange) ->
    url = getJsonProgrammesURL(appendTime, timerange, "GR", @channelname)
    @startTime = new Date()
    $(@tablename).attr({"loading":true});
    jQuery.ajaxQueue( {url:url, success:(programmes) => Tvlisting.appendTrCallBack( programmes, @tablename)});


  prependTr:( prependtime, timerange) ->
    url = getJsonProgrammesURL(prependtime, timerange, "GR", @channelname)
    $(@tablename).attr({"loading":true});
    height = $(@tablename + ' caption').height() + (240 * @ONE_MINUTE_HEIGHT)
    $(@tablename + ' caption').css("height", height.toString() + "px")
    jQuery.ajaxQueue( {url:url, success:(programmes) => Tvlisting.prependTrCallBack( programmes, @tablename)});

  @getChannelNameCallBack:(programmes, tablename) ->





  getLoading:( loading) ->
    if $(@tablename).attr("loading") == "true"
      return true
    return false
  @prependTrSpace:(currentTr) ->
    spaceStop = currentTr.attr("start")
    prevTr = currentTr.prev()
    if prevTr?
      spaceStart = prevTr.attr("stop")
    else
      return
    trSpace = @createSpaceTag(spaceStart, spaceStop)
    unless trSpace?
      return
    currentTr.before(trSpace)
