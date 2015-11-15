class @Tvlisting

  @TIME_RANGE : (60 * 4)
  @TIME_RANGE_CENTER : (60 * 4)
  @TIME_RANGE_UPPER : (60 * 4)
  @TIME_RANGE_LOWER : (60 * 4)

  @ONE_MINUTE_HEIGHT: 5
  @TITLE_LINE_LENGTH: 12
  @DAY_OF_WEEK = ["日", "月", "火", "水", "木", "金", "土"]

  constructor:(@channelname,
               tvlistingsId,
               tvlistingNamesId) ->
    @tvlistingNameTable = @createListingNameTable(tvlistingNamesId,
                                                  @channelname)
    @tvlistingsTable = @createListingTable(tvlistingsId, @channelname)
    @ajaxSetChannelName()

  @adjustProgrammeFontSize:(height) ->
    if height <= @ONE_MINUTE_HEIGHT
      return 5
    return 10

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

  @adjustProgrammesHeight:(trTags, displayAreaStart, displayAreaStop) ->
    for trTag in trTags
      programmeStart = Number(trTag.attr("start"))
      programmeStop = Number(trTag.attr("stop"))
      height = trTag.height()

      if programmeStart < displayAreaStart && programmeStop > displayAreaStop
        height = @calcProgrammeHeight( displayAreaStart, displayAreaStop)
      else if programmeStart < displayAreaStart
        height = @calcProgrammeHeight( displayAreaStart, programmeStop)
      else if programmeStop > displayAreaStop
        height = @calcProgrammeHeight( programmeStart, displayAreaStop)
      trTag.height(height)

      trTag.css("font-size", @adjustProgrammeFontSize( height))
      div = trTag.find('div')
      div.css("font-size", @adjustProgrammeFontSize( height))
      if div.size() > 0
        div.text(@adjustProgrammeTitle(div.attr("title"), height))

  @updateTrTagHeight:(tr, height) ->
    if tr == null
      return
    tr.css("height", height.toString() + "px")
    div = tr.children('div')
    div.css("font-size", @adjustProgrammeFontSize( height))
    if div.size() > 0
      div.text(@adjustProgrammeTitle(div.attr("title"), height))

  createListingNameTable:(tvlistingNamesId, channelname) ->
    tvlistingNameTable = $("<table id='" + channelname + "'></table>")
    tvlistingNameTable = tvlistingNameTable.appendTo("#" + tvlistingNamesId)
    tvlistingNameTable.addClass("""
                       table table-bordered table-condensed channelname
                       """)
    tvlistingNameTable.append("<tr><td></td></tr>")

  createListingTable:(tvlistingsId, channelname) ->
    tvlistingsTable = $("<table id='" + channelname + "' />")
    tvlistingsTable = tvlistingsTable.appendTo("#" + tvlistingsId)
    tvlistingsTable.addClass("""
                    table table-bordered table-condensed tvlisting
                    """)
    tvlistingsTable.css("width", "140px")
    tvlistingsTable.css("float", "left")

  @calcProgrammeHeight:( start, stop) ->
    return (( stop - start) / convertMinToMs(1)) * @ONE_MINUTE_HEIGHT;

  @getFirstTvProgramme:(table) ->
    result = table.children('tbody').children('tr[name=programme]:first')
    if result.size() == 0
      return null
    result

  @getLastTvProgramme:(table) ->
    result = table.children('tbody').children('tr[name=programme]:last')
    if result.size() == 0
      return null
    result

  @getFirstTvProgrammeTime:(table) ->
    result = table.children('tbody').children('tr[name=programme]:first')
    if result.size() == 0
      return null
    result.attr("start")

  @getLastTvProgrammeTime:(table) ->
    result = table.children('tbody').children('tr[name=programme]:last')
    if result.size() == 0
      return null
    result.attr("stop")

  @prependFirstBlankCallBack:(table) ->
    firstProgramme = Tvlisting.getFirstTvProgramme(table)
    if firstProgramme == null
      return
    start = parseInt(table.attr("start"),10)
    stop = parseInt(firstProgramme.attr("start"),10)
    tr = @createSpaceTrTag(start, stop)
    if tr == null
      return
    tr.attr({"name":"first_blank"})
    table.prepend(tr)

  prependFirstBlank: ->
    jQuery.ajaxQueue( {url:"/nop"
    success:(programmes) => Tvlisting.prependFirstBlankCallBack(@tvlistingsTable)
    })

  @removeFirstBlankCallBack:( table) ->
    tr = table.children('tbody').children('tr[name=first_blank]')
    tr.remove()

  removeFirstBlank: ->
    jQuery.ajaxQueue( {url:"/nop"
    success:(programmes) => Tvlisting.removeFirstBlankCallBack(@tvlistingsTable)
    })

  ajaxSetChannelName : ->
    url = getJsonChannelNameURL(@channelname)
    jQuery.ajaxQueue({url:url,success:(channelName) => @tvlistingNameTable.children('tbody').children('tr').children('td').text(channelName)})

  @removeTableSameProgrammes:(table, trTags) ->
    for trTag in trTags
      programmeStart = Number(trTag.attr("start"))
      programmeStop = Number(trTag.attr("stop"))
      for tr in table.children('tbody').children('tr')
        trStart = Number($(tr).attr("start"))
        trStop = Number($(tr).attr("stop"))
        if trStart != programmeStart || trStop != programmeStop
          continue
        tr.remove();

  @createSpaceTrTag:( start, stop) ->
    height = @calcProgrammeHeight( start, stop)
    if height == 0
      return null
    tr = $('<tr/>')
    tr.attr({"name":"blank"})
    tr.attr({"start":start})
    tr.attr({"stop":stop})
    tr.css("height", height + "px")
    return tr

  @createProgrammeTrTag:( programme) ->
    height = @calcProgrammeHeight( programme.start, programme.stop)
    start = new Date(programme.start)
    stop = new Date(programme.stop)
    infoTime = (" "+start.getDate()).slice(-2) + "日("
    infoTime = infoTime + @DAY_OF_WEEK[start.getDay()] + ")"
    infoTime = infoTime + ("0"+start.getHours()).slice(-2) + ":"
    infoTime = infoTime + ("0"+start.getMinutes()).slice(-2)
    infoTime = infoTime + "-" + ("0"+stop.getHours()).slice(-2) + ":"
    infoTime = infoTime + ("0"+stop.getMinutes()).slice(-2)

    tr = $('<tr/>')
    tr.attr({"class":"tvlisting"})
    tr.attr({"name":"programme"})
    tr.attr({"start":programme.start})
    tr.attr({"stop":programme.stop})
    tr.css("height", height.toString() + "px")

    tr.hover ->
      fontCol = "<font color='lightcyan'>"
      $('#infoTime').html(fontCol + infoTime + "</font>")
      $('.marquee').html(fontCol + programme.title + "</font>" + programme.desc)
      $('.marquee').marquee({
        speed: 10000,
        gap: 150,
        delayBeforeStart: 900,
        direction: 'left',
        duplicated: true,
        pauseOnHover: true
      })

    value = "<td class='" + programme.category + "'>"
    value = value + "<div class='tvlisting' "
    value = value + "title='" + programme.title + "' "
    value = value + "style='font-size:"+@adjustProgrammeFontSize(height)+"px;' "
    value = value + ">"
    value = value + @adjustProgrammeTitle(programme.title, height)
    value = value + "</div>"
    value = value + "</td>"
    tr.html(value)
    return tr

  @createProgrammeTrTagArray:(programmes, displayAreaStart, displayAreaStop) ->
    if programmes.length is 0
      return
    desIndex = 0
    trTags = []
    spaceStart = programmes[0].start
    for programme in programmes
      if programme.start >= displayAreaStop && programme.stop >= displayAreaStop
        continue
      if programme.start <= displayAreaStart && programme.stop <= displayAreaStart
        continue

      spaceStop = programme.start
      #番組との間に番組がない場合スペースを挿入する
      if spaceStart < spaceStop
        trTags[desIndex] = @createSpaceTrTag(spaceStart, spaceStop)
        desIndex++
      trTags[desIndex] = @createProgrammeTrTag(programme)
      desIndex++
      spaceStart = programme.stop
    return trTags

  @appendTrCallBack:(programmes, table) ->
    if programmes.length is 0
      return
    displayAreaStart = Number(table.attr("start"))
    displayAreaStop = Number(table.attr("stop"))
    trTags = @createProgrammeTrTagArray(programmes, displayAreaStart, displayAreaStop)
    if trTags.length is 0
      return
    #表示エリア内におさまるように番組の高さを調整
    @adjustProgrammesHeight(trTags, displayAreaStart, displayAreaStop)
    #テーブル内の被っている番組を消す
    @removeTableSameProgrammes(table, trTags)
    #テーブル内の最後の番組と追加する最初の番組の間にスペースがある場合
    #スペースを追加する
    tableLastProgrammeStop = Tvlisting.getLastTvProgrammeTime(table)
    programmeStart = Number(trTags[0].attr("start"))
    if tableLastProgrammeStop != null && programmeStart > tableLastProgrammeStop
      table.append(@createSpaceTrTag(tableLastProgrammeStop, programmeStart))

    Tvlisting.removeFirstBlankCallBack(table)
    table.append(trTags)
    Tvlisting.removeOutSideAreaCallBack(table)
    Tvlisting.prependFirstBlankCallBack(table)

  ajaxAppend:(nowTime, timerange=Tvlisting.TIME_RANGE) ->
    Tvlisting.removeFirstBlankCallBack(@tvlistingsTable)
    Tvlisting.prependFirstBlankCallBack(@tvlistingsTable)

    url = getJsonProgrammesURL(nowTime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.appendTrCallBack( programmes, @tvlistingsTable)
    #complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable)
    })

  @prependTrCallBack:(programmes, table) ->
    if programmes.length is 0
      table.attr({"loading":false});
      return
    displayAreaStart = Number(table.attr("start"))
    displayAreaStop = Number(table.attr("stop"))
    trTags = @createProgrammeTrTagArray(programmes, displayAreaStart, displayAreaStop)
    #表示エリア内におさまるように番組の高さを調整
    @adjustProgrammesHeight(trTags, displayAreaStart, displayAreaStop)
    #テーブル内の被っている番組を消す
    @removeTableSameProgrammes(table, trTags)
    trFirst = Tvlisting.getFirstTvProgramme(table)

    Tvlisting.removeFirstBlankCallBack(table)

    trFirst.before(trTags)

    Tvlisting.removeOutSideAreaCallBack(table)
    Tvlisting.prependFirstBlankCallBack(table)

  ajaxPrepend:(nowTime, timerange=Tvlisting.TIME_RANGE) ->
    Tvlisting.removeFirstBlankCallBack(@tvlistingsTable)
    Tvlisting.prependFirstBlankCallBack(@tvlistingsTable)

    url = getJsonProgrammesURL(nowTime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.prependTrCallBack( programmes, @tvlistingsTable)
    #complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable)
    })

  @removeOutSideAreaCallBack:( table) ->
    displayAreaStart = Number(table.attr("start"))
    displayAreaStop = Number(table.attr("stop"))
    for tr in table.children('tbody').children('tr')
      if !$(tr).attr("start")
        continue
      if !$(tr).attr("stop")
        continue
      trStart = Number($(tr).attr("start"))
      trStop = Number($(tr).attr("stop"))
      if trStart >= displayAreaStart &&
         trStart <= displayAreaStop &&
         trStop >= displayAreaStart &&
         trStop <= displayAreaStop
        continue
      tr.remove()

    trFirst = Tvlisting.getFirstTvProgramme(table)
    trStart = Number($(trFirst).attr("start"))
    trStop = Number($(trFirst).attr("stop"))
    @updateTrTagHeight(trFirst, @calcProgrammeHeight(trStart, trStop))
    if trStart < displayAreaStart && trStop < displayAreaStop
      trStart = displayAreaStart
      @updateTrTagHeight(trFirst, @calcProgrammeHeight(trStart, trStop))

    trLast = Tvlisting.getLastTvProgramme(table)
    trStart = Number($(trLast).attr("start"))
    trStop = Number($(trLast).attr("stop"))
    @updateTrTagHeight(trLast, @calcProgrammeHeight(trStart, trStop))
    if trStart > displayAreaStart && trStop > displayAreaStop
      trStop = displayAreaStop
      @updateTrTagHeight(trLast, @calcProgrammeHeight(trStart, trStop))

  removeOutSideArea: ->
    jQuery.ajaxQueue( {url:"/nop"
    success:(programmes) => Tvlisting.removeOutSideAreaCallBack(@tvlistingsTable)
    #complete:() => Tvlisting.adjustFirstHeight(@tvlistingsTable)
    })

  setDisplayArea:( start, stop) ->
    @tvlistingsTable.attr({"start": start})
    @tvlistingsTable.attr({"stop": stop})
    tableBody = @tvlistingsTable.children('tbody')
    if(tableBody.size() <= 0)
      appendStart = start
      appendStop = stop
      prependStart = start
      prependStop = start
    else
      firstProgramme = Tvlisting.getFirstTvProgramme(@tvlistingsTable)
      lastProgramme = Tvlisting.getLastTvProgramme(@tvlistingsTable)
      appendStart = Number(lastProgramme.attr("stop"))
      appendStop = stop
      prependStart = start
      prependStop = Number(firstProgramme.attr("start"))
    length = convertMsToMin(appendStop - appendStart)

    #@removeFirstBlank()
    if(length > 0)
      @ajaxAppend(new Date(appendStart), length)
    length = convertMsToMin(prependStop - prependStart)
    if(length > 0)
      @ajaxPrepend(new Date(prependStart), length)
    #@removeOutSideArea()
    #@prependFirstBlank()















  @createSpaceTrTagWithProgramme:( programmeA, programmeB) ->
    if !programmeA.attr("stop")
      return
    if !programmeB.attr("start")
      return
    programmeAStop = Number(programmeA.attr("stop"))
    programmeBStart = Number(programmeB.attr("start"))
    spaceTr = ""
    if programmeAStop != programmeBStart
      spaceTr = @createSpaceTrTag(programmeAStop, programmeBStart)
    return spaceTr

















  @dropFirstTrCallBack:( table) ->
    nowSec = nowTime.getTime()
    displayAreaStart = Number(table.attr("start"))
    displayAreaStop = Number(table.attr("stop"))

    for tr in table.children('tbody').children('tr')
      trStart = Number($(tr).attr("start"))
      trStop = Number($(tr).attr("stop"))
      if trStart >= nowSec || trStop >= nowSec
        continue
      tr.remove()

    trFirst = table.children('tbody').children('tr#first').next()
    trStart = Number($(trFirst).attr("start"))
    trStop = Number($(trFirst).attr("stop"))
    if trStart < nowSec
      @updateTrTagHeight(trFirst, @calcProgrammeHeight(trStart, trStop))
    Tvlisting.adjustFirstHeight(table)

  @dropLastTrCallBack:( table) ->
    nowSec = nowTime.getTime()

  dropFirst: ->
    jQuery.ajaxQueue( {url:"/nop"
    complete:() => Tvlisting.dropFirstTrCallBack(@tvlistingsTable)
    })

  dropLast:() ->
    jQuery.ajaxQueue( {url:"/nop"
    complete:() => Tvlisting.dropLastTrCallBack(@tvlistingsTable)
    })










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
    trSpace = @createSpaceTrTag(spaceStart, spaceStop)
    unless trSpace?
      return
    currentTr.before(trSpace)
