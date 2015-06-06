class @Tvlisting
  @TIME_RANGE : (60 * 4)
  @ONE_MINUTE_HEIGHT: 5
  @TITLE_LINE_LENGTH: 12
  @DAY_OF_WEEK = ["日", "月", "火", "水", "木", "金", "土"]

  constructor:(@channelname, tvlistingsId, tvlistingNamesId, createtime) ->
    @tvlistingNameTable = @createListingNameTable(tvlistingNamesId, @channelname)
    @tvlistingsTable = @createListingTable(tvlistingsId, @channelname)
    @ajaxSetChannelName()
    @ajaxAppendListingTable(createtime)

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

    td = $('<td/>')
    td.attr({"class":programme.category})
    td.hover ->
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

    div = $('<div/>')
    div.attr({"class":"tvlisting"})
    div.css("height", height + "px")
    div.css("font-size", @adjustProgrammeFontSize( height) + "px")
    div.text( @adjustProgrammeTitle(programme.title, height))

    div.appendTo(td)
    td.appendTo(tr)
    return tr

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

  @adjustFirstHeight:(table) ->
    firstBuffer = table.children('tbody').children('tr:first')
    firstProgramme = firstBuffer.next()
    start = new Date(parseInt(firstProgramme.attr("start"),10))
    stop = new Date(parseInt(firstProgramme.attr("start"),10))
    start.setMinutes(0)

    height = @calcProgrammeHeight(start, stop)
    firstBuffer.css("height", height + "px")

  @appendTrCallBack:(programmes, table) ->
    if programmes.length is 0
      table.attr({"loading":false});
      return

    trLast = table.children('tbody').children('tr:last')
    if trLast.attr("id") == "first"
      spaceStart = programmes[0].start
    else
      spaceStart = trLast.attr("stop")

    for programme in programmes
      spaceStop = programme.start
      if spaceStart != spaceStop
        table.append(@createSpaceTag(spaceStart, spaceStop))
      table.append(@createProgrammeTag(programme))
      spaceStart = programme.stop

  createListingNameTable:(tvlistingNamesId, channelname) ->
    tvlistingNameTable = $("<table id='" + channelname + "'></table>").appendTo("#" + tvlistingNamesId)
    tvlistingNameTable.addClass("table table-bordered table-condensed channelname")
    tvlistingNameTable.append("<tr><td></td></tr>")

  createListingTable:(tvlistingsId, channelname) ->
    tvlistingTable = $("<table id='" + channelname + "' />").appendTo("#" + tvlistingsId)
    tvlistingTable.addClass("table table-bordered table-condensed tvlisting")
    tvlistingTable.css("width", "140px")
    tvlistingTable.css("float", "left")
    @trFirst = $('<tr/>')
    @trFirst.attr("id","first")
    @trFirst.css("height", "0px")
    tvlistingTable.append(@trFirst)

  ajaxSetChannelName:() ->
    url = getJsonChannelNameURL(@channelname)
    jQuery.ajaxQueue( {url:url, success:(channelName) => @tvlistingNameTable.children('tbody').children('tr').children('td').text(channelName)});

  ajaxAppendListingTable:(createtime, timerange=Tvlisting.TIME_RANGE) ->
    url = getJsonProgrammesURL(createtime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.appendTrCallBack( programmes, @tvlistingsTable, createtime)
    complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable)
    })




















  appendTr:(appendTime, timerange) ->
    url = getJsonProgrammesURL(appendTime, timerange, "GR", @channelname)
    @startTime = new Date()
    $(@tablename).attr({"loading":true});
    jQuery.ajaxQueue( {url:url, success:(programmes) => Tvlisting.appendTrCallBack( programmes, @tablename)});

  @prependTrCallBack:(programmes, tablename) ->
    table = $(tablename)
    if programmes.length is 0
      table.attr({"loading":false});
      return
    height = 0

    tr = $( tablename + " tr:first")
    start = parseInt( tr.attr("start"), 10)
    programmeLast = programmes[programmes.length-1]

    if programmeLast.stop isnt start
      table.prepend( @createListingTableSpaceTag( start, programmeLast.stop))
      height = height + @calcProgrammeHeight( programmeLast.stop, start)
    table.prepend(@createProgrammeTag( programmeLast))
    height = height + @calcProgrammeHeight( programmeLast.start, programmeLast.stop)

    i = programmes.length - 1
    while i--
      if programmes[i].stop isnt programmes[i+1].start
        table.prepend(@createListingTableSpaceTag( programmes[i+1].start, programmes[i].stop))
        height = height + @calcProgrammeHeight( programmes[i].stop, programmes[i+1].start)
      height = height + @calcProgrammeHeight( programmes[i].start, programmes[i].stop)
      table.prepend(@createProgrammeTag( programmes[i]));
    table.attr({"loading":false});
    height = $(tablename + ' caption').height() - height
    $(tablename + ' caption').css("height", height.toString() + "px")

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
