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

  @setTableStatus:(table, status) ->
    table.attr("status", status)

  @getTableFirstProgramme:(table) ->
    result = table.children('tbody').children('tr:first')
    if result.size() == 0
      return null
    result

  @getTableLastProgramme:(table) ->
    result = table.children('tbody').children('tr:last')
    if result.size() == 0
      return null
    result

  @calcProgrammeHeight:( start, stop) ->
    return (( stop - start) / convertMinToMs(1)) * Tvlisting.ONE_MINUTE_HEIGHT;

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

    if adjustTitle.length != title.length && adjustTitle.length > 0
      adjustTitle = adjustTitle + "..."
    return adjustTitle

  @adjustProgrammeHeight:(trTag, displayAreaStart, displayAreaStop) ->
    programmeStart = Number(trTag.attr("start"))
    programmeStop = Number(trTag.attr("stop"))
    height = Tvlisting.calcProgrammeHeight( programmeStart, programmeStop)

    if programmeStart < displayAreaStart && programmeStop > displayAreaStop
      height = Tvlisting.calcProgrammeHeight( displayAreaStart, displayAreaStop)
    else if programmeStart < displayAreaStart
      height = Tvlisting.calcProgrammeHeight( displayAreaStart, programmeStop)
    else if programmeStop > displayAreaStop
      height = Tvlisting.calcProgrammeHeight( programmeStart, displayAreaStop)
    trTag.height(height)

    trTag.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
    div = trTag.find('div')
    div.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
    if div.size() > 0
      div.text(@adjustProgrammeTitle(div.attr("title"), height))

  @adjustProgrammesHeight:(trTags, displayAreaStart, displayAreaStop) ->
    for trTag in trTags
      programmeStart = Number(trTag.attr("start"))
      programmeStop = Number(trTag.attr("stop"))
      height = Tvlisting.calcProgrammeHeight( programmeStart, programmeStop)

      if programmeStart < displayAreaStart && programmeStop > displayAreaStop
        height = Tvlisting.calcProgrammeHeight( displayAreaStart, displayAreaStop)
      else if programmeStart < displayAreaStart
        height = Tvlisting.calcProgrammeHeight( displayAreaStart, programmeStop)
      else if programmeStop > displayAreaStop
        height = Tvlisting.calcProgrammeHeight( programmeStart, displayAreaStop)
      trTag.height(height)

      trTag.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
      div = trTag.find('div')
      div.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
      if div.size() > 0
        div.text(@adjustProgrammeTitle(div.attr("title"), height))

  createListingNameTable:(tvlistingNamesId, channelname) ->
    tvlistingNameTable = $("<table id='" + channelname + "'></table>")
    tvlistingNameTable = tvlistingNameTable.appendTo("#" + tvlistingNamesId)
    tvlistingNameTable.addClass("""
                       table table-bordered table-condensed channelname
                       """)
    tvlistingNameTable.append("<tr><td></td></tr>")

  ajaxSetChannelName : ->
    url = getJsonChannelNameURL(@channelname)
    jQuery.ajaxQueue({url:url,success:(channelName) => @tvlistingNameTable.children('tbody').children('tr').children('td').text(channelName)})

  @createSpaceTrTag:( start, stop) ->
    height = Tvlisting.calcProgrammeHeight( start, stop)
    if height <= 0
      return null
    tr = $('<tr/>')
    tr.attr({"name":"blank"})
    tr.attr({"start":start})
    tr.attr({"stop":stop})
    tr.css("height", height + "px")
    return tr

  createLoadingTrTag:( start, stop) ->
    height = Tvlisting.calcProgrammeHeight( start, stop)
    if height <= 0
      return null

    td = "<td class='loading'>"

    tr = $('<tr/>')
    tr.attr({"name":"loading"})
    tr.attr({"start":start})
    tr.attr({"stop":stop})
    tr.css("height", height + "px")
    tr.html(td)
    return tr

  updateTrTagHeight:(tr, height) ->
    if tr == null
      return
    tr.css("height", height.toString() + "px")
    div = tr.children('div')
    div.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
    if div.size() > 0
      div.text(@adjustProgrammeTitle(div.attr("title"), height))

  adjustTableFirstProgramme:(table, displayAreaStart, displayAreaStop) ->
    firstProgramme = Tvlisting.getTableFirstProgramme(table)
    if firstProgramme == null
      return
    trStart = Number($(firstProgramme).attr("start"))
    trStop = Number($(firstProgramme).attr("stop"))
    if trStart < displayAreaStart && trStop < displayAreaStop
      trStart = displayAreaStart
      @updateTrTagHeight(firstProgramme, Tvlisting.calcProgrammeHeight(trStart, trStop))

  adjustTableLastProgramme:(table, displayAreaStart, displayAreaStop) ->
    lastProgramme = Tvlisting.getTableLastProgramme(table)
    if lastProgramme == null
      return
    trStart = Number($(lastProgramme).attr("start"))
    trStop = Number($(lastProgramme).attr("stop"))
    if trStart > displayAreaStart && trStop > displayAreaStop
      trStop = displayAreaStop
      @updateTrTagHeight(lastProgramme, Tvlisting.calcProgrammeHeight(trStart, trStop))

  @prependTableFirstBlank:(table, start) ->
    firstProgramme = Tvlisting.getTableFirstProgramme(table)
    if firstProgramme == null
      return
    stop = parseInt(firstProgramme.attr("start"),10)
    tr = Tvlisting.createSpaceTrTag(start, stop)
    if tr == null
      return
    tr.attr({"name":"first_blank"})
    table.prepend(tr)

  @removeTableFirstBlank:(table) ->
    tr = table.children('tbody').children('tr[name=first_blank]')
    tr.remove()

  @removeTableOutSideAreaProgramme:(table, displayAreaStart, displayAreaStop) ->
    for tr in table.children('tbody').children('tr')
      trStart = Number($(tr).attr("start"))
      trStop = Number($(tr).attr("stop"))
      if (trStart >= displayAreaStart &&
         trStart < displayAreaStop) ||
         (trStop > displayAreaStart &&
         trStop < displayAreaStop)
        Tvlisting.adjustProgrammeHeight($(tr), displayAreaStart, displayAreaStop)
        continue
      tr.remove()

  @createProgrammeTrTag:( programme) ->
    height = Tvlisting.calcProgrammeHeight( programme.start, programme.stop)
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
    value = value + "style='font-size:"+Tvlisting.adjustProgrammeFontSize(height)+"px;' "
    value = value + ">"
    value = value + @adjustProgrammeTitle(programme.title, height)
    value = value + "</div>"
    value = value + "</td>"
    tr.html(value)
    return tr

  @createProgrammeTrTagArray:(programmes) ->
    if programmes.length is 0
      return
    desIndex = 0
    trTags = []
    spaceStart = programmes[0].start
    for programme in programmes
      spaceStop = programme.start
      #番組との間に番組がない場合スペースを挿入する
      if spaceStart < spaceStop
        trTags[desIndex] = @createSpaceTrTag(spaceStart, spaceStop)
        desIndex++
      trTags[desIndex] = @createProgrammeTrTag(programme)
      desIndex++
      spaceStart = programme.stop
    return trTags

  @removeTableSameProgrammes:(table, programmes) ->
    for programme in programmes
      @removeTableProgramm(table, programme.start, programme.stop)

  @removeTableProgramm:(table, start, stop) ->
    for tr in table.children('tbody').children('tr[name=programme]')
      trStart = Number($(tr).attr("start"))
      trStop = Number($(tr).attr("stop"))
      if trStart != start || trStop != start
        continue
      tr.remove()

  prependLoadingTag:(table, start, stop) ->
    trTag = @createLoadingTrTag(start, stop)
    table.prepend(trTag)

  appendLoadingTag:(table, start, stop) ->
    trTag = @createLoadingTrTag(start, stop)
    table.append(trTag)

  @setProgrammesCallBack:(table, programmes, displayStart, displayStop) ->
    if programmes.length <= 1
      return

    @removeTableSameProgrammes(table, programmes)

    firstProgramme = Tvlisting.getTableFirstProgramme(table)
    if(firstProgramme == null)
      Tvlisting.appendProgrammes(table, programmes)
    else if(programmes[0].start < Number(firstProgramme.attr("start")))
      Tvlisting.prependProgrammes(table, programmes)
    else
      Tvlisting.appendProgrammes(table, programmes)

  getTableStatus : ->
    @tvlistingsTable.attr("status")

  setProgrammes:(displayAreaStart, displayAreaStop) ->
    Tvlisting.removeTableOutSideAreaProgramme(@tvlistingsTable, displayAreaStart, displayAreaStop)
    @adjustTableFirstProgramme(@tvlistingsTable, displayAreaStart, displayAreaStop)
    @adjustTableLastProgramme(@tvlistingsTable, displayAreaStart, displayAreaStop)

    firstProgramme = Tvlisting.getTableFirstProgramme(@tvlistingsTable)
    lastProgramme = Tvlisting.getTableLastProgramme(@tvlistingsTable)
    if(firstProgramme == null && lastProgramme == null)
      @appendLoadingTag(@tvlistingsTable, displayAreaStart, displayAreaStop)
      @ajaxMergeProgrammes(displayAreaStart, displayAreaStop, displayAreaStart, displayAreaStop)
    if(firstProgramme != null)
      firstProgrammeStart = Number(firstProgramme.attr("start"))
      if(displayAreaStart < firstProgrammeStart)
        @prependLoadingTag(@tvlistingsTable, displayAreaStart, firstProgrammeStart)
        @ajaxMergeProgrammes(displayAreaStart, firstProgrammeStart, displayAreaStart, displayAreaStop)
    if(lastProgramme != null)
      lastProgrammeStop = Number(lastProgramme.attr("stop"))
      if(displayAreaStop > lastProgrammeStop)
        @appendLoadingTag(@tvlistingsTable, lastProgrammeStop, displayAreaStop)
        @ajaxMergeProgrammes(lastProgrammeStop, displayAreaStop, displayAreaStart, displayAreaStop)

  @mergeProgrammesCallBack:(table, programmes, start, stop) ->
    selector = 'tr[name="loading"][start="' + start + '"][stop="' + stop + '"]'
    loadingTr = table.children('tbody').children(selector)
    if(loadingTr == null)
      return
    programmeTags = @createProgrammeTrTagArray(programmes)
    if programmeTags.length is 0
      return
    Tvlisting.adjustProgrammesHeight(programmeTags, start, stop)

    programmesFirstTime = programmeTags[0].attr("start")
    programmesLastTime = programmeTags[programmeTags.length-1].attr("stop")
    if start < programmesFirstTime
      spaceTag = Tvlisting.createSpaceTrTag(start, programmesFirstTime)
      programmeTags.unshift(spaceTag)
    if stop > programmesLastTime
      spaceTag = Tvlisting.createSpaceTrTag(programmesLastTime, stop)
      programmeTags.push(spaceTag)

    prevTr = loadingTr.prev()
    if prevTr.attr("name") == "programme" && prevTr.attr("start") == programmeTags[0].attr("start")
      prevTr.remove()
    nextTr = loadingTr.next()
    if nextTr.attr("name") == "programme" && nextTr.attr("start") == programmeTags[programmeTags.length-1].attr("start")
      nextTr.remove()

    loadingTr.before(programmeTags)
    loadingTr.remove()

  ajaxMergeProgrammes:(start, stop, displayAreaStart, displayAreaStop) ->
    length =  convertMsToMin(stop - start)
    url = getJsonProgrammesURL(new Date(start), length, "GR", @channelname)

    Tvlisting.setTableStatus(@tvlistingsTable, "loading")
    jQuery.ajaxQueue( {url:url,
    context:{
      start: start,
      stop: stop,
      displayAreaStart: displayAreaStart,
      displayAreaStop: displayAreaStop,
      table: @tvlistingsTable
    },
    success:(programmes) ->
      Tvlisting.mergeProgrammesCallBack(this.table, programmes, this.start, this.stop)
      Tvlisting.setTableStatus(this.table, "finish")
    })














  @prependProgrammesCallback:(table, programmes, displayAreaStart, displayAreaStop) ->
    trTags = @createProgrammeTrTagArray(programmes)
    if trTags.length is 0
      return

    Tvlisting.removeTableSameProgrammes(table, programmes)
    Tvlisting.adjustProgrammesHeight(trTags, displayAreaStart, displayAreaStop)

    spaceStart = Number(trTags[trTags.length-1].attr("stop"))
    spaceStop = displayAreaStop
    firstProgramme = Tvlisting.getTableFirstProgramme(table)
    if(firstProgramme != null)
      spaceStop = Number(firstProgramme.attr("start"))
    if spaceStart < spaceStop
      table.prepend(@createSpaceTrTag(spaceStart, spaceStop))

    table.prepend(trTags)

  createListingTable:(tvlistingsId, channelname) ->
    tvlistingsTable = $("<table id='" + channelname + "' />")
    tvlistingsTable = tvlistingsTable.appendTo("#" + tvlistingsId)
    tvlistingsTable.addClass("""
                    table table-bordered table-condensed tvlisting
                    """)
    tvlistingsTable.css("width", "140px")
    tvlistingsTable.css("float", "left")

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

  @appendTrCallBack:(programmes, table) ->
    if programmes.length <= 1
      return
    displayAreaStart = programmes[0].start
    displayAreaStop = programmes[0].stop
    programmes.shift()
    trTags = @createProgrammeTrTagArray(programmes)
    if trTags.length is 0
      return
    #表示エリア内におさまるように番組の高さを調整
    @adjustFirstProgramme(table, displayAreaStart, displayAreaStop)
    @adjustLastProgramme(table, displayAreaStart, displayAreaStop)

    @removeFirstBlank(table)
    #テーブル内の被っている番組を消す
    @removeTableSameProgrammes(table, trTags)
    #テーブル内の最後の番組と追加する最初の番組の間にスペースがある場合
    #スペースを追加する
    lastTvProgramme = Tvlisting.getLastTvProgramme(table)
    if(lastTvProgramme != null)
      lastTvProgrammeStop = Number(lastTvProgramme.attr("stop"))
      programmeStart = Number(trTags[0].attr("start"))
      if programmeStart > lastTvProgrammeStop
        table.append(@createSpaceTrTag(lastTvProgrammeStop, programmeStart))

    #番組を追加
    table.append(trTags)
    @prependFirstBlank(table, displayAreaStart)


  ajaxAppend:(displayTime, displayLength, nowTime, timerange=Tvlisting.TIME_RANGE) ->
    url = getJsonProgrammesURL(displayTime, displayLength, nowTime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.appendTrCallBack( programmes, @tvlistingsTable)
    })

  @prependTrCallBack:(programmes, table) ->
    if programmes.length <= 1
      return
    displayAreaStart = programmes[0].start
    displayAreaStop = programmes[0].stop
    programmes.shift()
    trTags = @createProgrammeTrTagArray(programmes)
    if trTags.length is 0
      return

    @removeFirstBlank(table)
    #テーブル内の被っている番組を消す
    @removeTableSameProgrammes(table, trTags)
    #テーブル内の最後の番組と追加する最初の番組の間にスペースがある場合
    #スペースを追加する
    lastTvProgramme = Tvlisting.getLastTvProgramme(table)
    if(lastTvProgramme != null)
      lastTvProgrammeStop = Number(lastTvProgramme.attr("stop"))
      programmeStart = Number(trTags[0].attr("start"))
      if programmeStart > lastTvProgrammeStop
        table.append(@createSpaceTrTag(lastTvProgrammeStop, programmeStart))
    #番組を追加
    trFirst = Tvlisting.getFirstTvProgramme(table)
    trFirst.before(trTags)
    @prependFirstBlank(table, displayAreaStart)
    #表示エリア内におさまるように番組の高さを調整
    @adjustFirstProgramme(table, displayAreaStart, displayAreaStop)
    @adjustLastProgramme(table, displayAreaStart, displayAreaStop)

  ajaxPrepend:(displayTime, displayLength, nowTime, timerange=Tvlisting.TIME_RANGE) ->
    url = getJsonProgrammesURL(displayTime, displayLength, nowTime, timerange, "GR", @channelname)
    jQuery.ajaxQueue( {url:url
    success:(programmes) => Tvlisting.prependTrCallBack( programmes, @tvlistingsTable)
    })

  @adjustFirstProgramme:(table, displayAreaStart, displayAreaStop) ->
    firstProgramme = @getFirstTvProgramme(table)
    if firstProgramme == null
      return
    trStart = Number($(firstProgramme).attr("start"))
    trStop = Number($(firstProgramme).attr("stop"))
    if trStart < displayAreaStart && trStop < displayAreaStop
      trStart = displayAreaStart
      @updateTrTagHeight(firstProgramme, Tvlisting.calcProgrammeHeight(trStart, trStop))

  @adjustLastProgramme:(table, displayAreaStart, displayAreaStop) ->
    lastProgramme = @getLastTvProgramme(table)
    if lastProgramme == null
      return
    trStart = Number($(lastProgramme).attr("start"))
    trStop = Number($(lastProgramme).attr("stop"))
    if trStart > displayAreaStart && trStop > displayAreaStop
      trStop = displayAreaStop
      @updateTrTagHeight(lastProgramme, Tvlisting.calcProgrammeHeight(trStart, trStop))

  @adjustProgrammesCallback:(table, displayAreaTime) ->
    @removeFirstBlank(table)
    @removeOutSideAreaProgramme(table, displayAreaTime.start, displayAreaTime.stop)
    @adjustFirstProgramme(table, displayAreaTime.start, displayAreaTime.stop)
    @adjustLastProgramme(table, displayAreaTime.start, displayAreaTime.stop)
    @prependFirstBlank(table, displayAreaTime.start)

  @adjustProgrammes:(table, displayStart, displayStop) ->
    @removeFirstBlank(table)
    @removeOutSideAreaProgramme(table, displayStart, displayStop)
    @adjustFirstProgramme(table, displayStart, displayStop)
    @adjustLastProgramme(table, displayStart, displayStop)
    @prependFirstBlank(table, displayStart)

  ajaxAdjustProgrammes:(nowTime, timerange) ->
    url = getJsonDisplayAreaURL(nowTime, timerange)
    jQuery.ajaxQueue( {url:url
    success:(displayAreaTime) => Tvlisting.adjustProgrammesCallback(@tvlistingsTable, displayAreaTime)
    })

  setDisplayArea:( start, stop) ->
    firstProgramme = Tvlisting.getFirstTvProgramme(@tvlistingsTable)
    lastProgramme = Tvlisting.getLastTvProgramme(@tvlistingsTable)
    if(firstProgramme != null && lastProgramme != null)
      appendStart = Number(lastProgramme.attr("stop"))
      appendStop = stop
      prependStart = start
      prependStop = Number(firstProgramme.attr("start"))
    else
      appendStart = start
      appendStop = stop
      prependStart = stop
      prependStop = stop

    displayLength =  convertMsToMin(stop - start)

    length = convertMsToMin(stop - start)
    #@ajaxAdjustProgrammes(new Date(start), length)
    Tvlisting.adjustProgrammes(@tvlistingsTable, start, stop)

    length = convertMsToMin(appendStop - appendStart)
    if(length > 0)
      @ajaxAppend(new Date(start), displayLength, new Date(appendStart), length)

    length = convertMsToMin(prependStop - prependStart)
    if(length > 0)
      @ajaxPrepend(new Date(start), displayLength, new Date(prependStart), length)















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
      @updateTrTagHeight(trFirst, Tvlisting.calcProgrammeHeight(trStart, trStop))
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
