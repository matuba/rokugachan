class @Tvlisting

  @TIME_RANGE : (60 * 4)
  @TIME_RANGE_CENTER : (60 * 4)
  @TIME_RANGE_UPPER : (60 * 4)
  @TIME_RANGE_LOWER : (60 * 4)

  @ONE_MINUTE_HEIGHT: 5
  @TITLE_LINE_LENGTH: 12
  @DAY_OF_WEEK = ["日", "月", "火", "水", "木", "金", "土"]

  constructor:(@channelname, tvlistingsId, tvlistingNamesId, @createtime, startDisplay, stopDisplay) ->
    @tvlistingNameTable = @createListingNameTable(tvlistingNamesId, @channelname)
    @tvlistingsTable = @createListingTable(tvlistingsId, @channelname, @createtime)
    #常に１番最初のプログラムとしておいておく、高さの調整で使う
    @firstProgramme =  @tvlistingsTable.children('tbody').children('tr:first')
    @ajaxSetChannelName()
    @setDisplayArea( startDisplay, stopDisplay)
    @ajaxAppend(createtime)

  createListingNameTable:(tvlistingNamesId, channelname) ->
    tvlistingNameTable = $("<table id='" + channelname + "'></table>").appendTo("#" + tvlistingNamesId)
    tvlistingNameTable.addClass("table table-bordered table-condensed channelname")
    tvlistingNameTable.append("<tr><td></td></tr>")

  createListingTable:(tvlistingsId, channelname, createtime) ->
    tvlistingsTable = $("<table id='" + channelname + "' />").appendTo("#" + tvlistingsId)
    tvlistingsTable.addClass("table table-bordered table-condensed tvlisting")
    tvlistingsTable.css("width", "140px")
    tvlistingsTable.css("float", "left")
    trFirst = $('<tr/>')
    trFirst.attr({"id":"first"})
    trFirst.attr({"start":0})
    trFirst.attr({"stop":createtime.getTime()})
    trFirst.css("height", "0px")
    tvlistingsTable.append(trFirst)

  @calcProgrammeHeight:( start, stop) ->
    return (( stop - start) / convertMinToMs(1)) * @ONE_MINUTE_HEIGHT;

  @createSpaceTag:( start, stop) ->
    height = @calcProgrammeHeight( start, stop)
    if height is 0
      return
    tr = $('<tr/>')
    tr.attr({"id":"blank"})
    tr.attr({"start":start})
    tr.attr({"stop":stop})
    tr.css("height", height + "px")
    return tr

  @adjustProgrammeTitle:(title, height) ->
    adjustTitle = title
    if height < @ONE_MINUTE_HEIGHT * 2
      adjustTitle = ""
    else if height <= @ONE_MINUTE_HEIGHT * 3
      adjustTitle = title.substring(0, @TITLE_LINE_LENGTH)
    else if height <= @ONE_MINUTE_HEIGHT * 5
      adjustTitle = title.substring(0, @TITLE_LINE_LENGTH * 2)
    else if height <= @ONE_MINUTE_HEIGHT * 7
      adjustTitle = title.substring(0, @TITLE_LINE_LENGTH * 3)

    if adjustTitle.lngth != title.length && adjustTitle.length > 0
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
    value = value + "<div class='tvlisting' "
    value = value + "     title='" + programme.title + "' "
    value = value + "     style='font-size:" + @adjustProgrammeFontSize( height) + "px;' "
    value = value + ">"
    value = value + @adjustProgrammeTitle(programme.title, height)
    value = value + "</div>"
    value = value + "</td>"
    tr.html(value)
    return tr

  @adjustFirstHeight:(table) ->
    firstBuffer = table.children('tbody').children('tr#first')
    firstProgramme = firstBuffer.next()
    start = new Date(parseInt(table.attr("start"),10))
    stop = new Date(parseInt(firstProgramme.attr("start"),10))

    height = @calcProgrammeHeight(start, stop)
    firstBuffer.css("height", height + "px")

  ajaxSetChannelName : ->
    url = getJsonChannelNameURL(@channelname)
    jQuery.ajaxQueue( {url:url, success:(channelName) => @tvlistingNameTable.children('tbody').children('tr').children('td').text(channelName)});

  setDisplayArea:( start, stop) ->
    @tvlistingsTable.attr({"start": start});
    @tvlistingsTable.attr({"stop": stop});

  @createProgrammeTagArray:(programmes, displayAreaStart, displayAreaStop) ->
    if programmes.length is 0
      return
    desIndex = 0
    programmeTags = []
    spaceStart = programmes[0].start
    for programme in programmes
      if programme.start >= displayAreaStop && programme.stop >= displayAreaStop
        continue
      if programme.start <= displayAreaStart && programme.stop <= displayAreaStart
        continue

      spaceStop = programme.start
      #番組との間に番組がない場合スペースを挿入する
      if spaceStart < spaceStop
        programmeTags[desIndex] = @createSpaceTag(spaceStart, spaceStop)
        desIndex++
      programmeTags[desIndex] = @createProgrammeTag(programme)
      desIndex++
      spaceStart = programme.stop
    return programmeTags

  @adjustProgrammesHeight:(programmeTags, appendStart, appendStop) ->
    for programmeTag in programmeTags
      programmeTagStart = Number(programmeTag.attr("start"))
      programmeTagStop = Number(programmeTag.attr("stop"))
      height = programmeTag.height()

      if programmeTagStart < appendStart && programmeTagStop > appendStop
        height = @calcProgrammeHeight( appendStart, appendStop)
      else if programmeTagStart < appendStart
        height = @calcProgrammeHeight( appendStart, programmeTagStop)
      else if programmeTagStop > appendStop
        height = @calcProgrammeHeight( programmeTagStart, appendStop)
      programmeTag.height(height)

      programmeTag.css("font-size", @adjustProgrammeFontSize( height))
      div = programmeTag.find('div')
      if div.size() > 0
        div.text(@adjustProgrammeTitle(div.attr("title"), height))

  @removeTableSameProgrammes:(table, programmeTags) ->
    for programmeTag in programmeTags
      programmeTagStart = Number(programmeTag.attr("start"))
      programmeTagStop = Number(programmeTag.attr("stop"))
      for tr in table.children('tbody').children('tr')
        trStart = Number($(tr).attr("start"))
        trStop = Number($(tr).attr("stop"))
        if trStart != programmeTagStart || trStop != programmeTagStop
          continue
        tr.remove();

  @appendTrCallBack:(programmes, table) ->
    if programmes.length is 0
      return
    displayAreaStart = Number(table.attr("start"))
    displayAreaStop = Number(table.attr("stop"))
    programmeTags = @createProgrammeTagArray(programmes, displayAreaStart, displayAreaStop)
    #表示エリア内におさまるように番組の高さを調整
    @adjustProgrammesHeight(programmeTags, displayAreaStart, displayAreaStop)
    #テーブル内の被っている番組を消す
    @removeTableSameProgrammes(table, programmeTags)
    table.append(programmeTags)

  ajaxAppend:(nowTime, timerange=Tvlisting.TIME_RANGE) ->

    url = getJsonProgrammesURL(nowTime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.appendTrCallBack( programmes, @tvlistingsTable)
    complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable)
    })


  @prependTrCallBack:(programmes, table) ->
    if programmes.length is 0
      table.attr({"loading":false});
      return
    displayAreaStart = Number(table.attr("start"))
    displayAreaStop = Number(table.attr("stop"))
    programmeTags = @createProgrammeTagArray(programmes, displayAreaStart, displayAreaStop)
    #表示エリア内におさまるように番組の高さを調整
    @adjustProgrammesHeight(programmeTags, displayAreaStart, displayAreaStop)
    #テーブル内の被っている番組を消す
    @removeTableSameProgrammes(table, programmeTags)

    trFirst = table.children('tbody').children('tr#first').next()
    trFirst.before(programmeTags)

  ajaxPrepend:(nowTime, timerange=Tvlisting.TIME_RANGE) ->
    url = getJsonProgrammesURL(nowTime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.prependTrCallBack( programmes, @tvlistingsTable)
    complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable)
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
