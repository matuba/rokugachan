class @Tvlisting
  @ONE_MINUTE_HEIGHT: 5
  @TITLE_LINE_LENGTH: 12
  @DAY_OF_WEEK = ["日", "月", "火", "水", "木", "金", "土"]

  @showProgrammeClass = ""

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

  @adjustProgrammeHeight:(trTag, areaStart, areaStop) ->
    programmeStart = Number(trTag.attr("start"))
    programmeStop = Number(trTag.attr("stop"))
    height = Tvlisting.calcProgrammeHeight( programmeStart, programmeStop)

    if programmeStart < areaStart && programmeStop > areaStop
      height = Tvlisting.calcProgrammeHeight( areaStart, areaStop)
    else if programmeStart < areaStart
      height = Tvlisting.calcProgrammeHeight( areaStart, programmeStop)
    else if programmeStop > areaStop
      height = Tvlisting.calcProgrammeHeight( programmeStart, areaStop)
    trTag.height(height)

    trTag.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
    div = trTag.find('div')
    div.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
    if div.size() > 0
      div.text(@adjustProgrammeTitle(div.attr("title"), height))

  @adjustTrArrayHeight:(trTags, areaStart, areaStop) ->
    for trTag in trTags
      Tvlisting.adjustProgrammeHeight(trTag, areaStart, areaStop)

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

  @createLoadingTrTag:( start, stop) ->
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

  @updateTrTagHeight:(tr, height) ->
    if tr == null
      return
    tr.css("height", height.toString() + "px")
    div = tr.children('div')
    div.css("font-size", Tvlisting.adjustProgrammeFontSize( height))
    if div.size() > 0
      div.text(@adjustProgrammeTitle(div.attr("title"), height))

  @adjustFirstProgramme:(table, areaStart, areaStop) ->
    firstProgramme = Tvlisting.getTableFirstProgramme(table)
    if firstProgramme == null
      return
    trStart = Number($(firstProgramme).attr("start"))
    trStop = Number($(firstProgramme).attr("stop"))
    if trStart < areaStart && trStop < areaStop
      trStart = areaStart
      height = Tvlisting.calcProgrammeHeight(trStart, trStop)
      Tvlisting.updateTrTagHeight(firstProgramme, height)

  @adjustLastProgramme:(table, areaStart, areaStop) ->
    lastProgramme = Tvlisting.getTableLastProgramme(table)
    if lastProgramme == null
      return
    trStart = Number($(lastProgramme).attr("start"))
    trStop = Number($(lastProgramme).attr("stop"))
    if trStart > areaStart && trStop > areaStop
      trStop = areaStop
      height = Tvlisting.calcProgrammeHeight(trStart, trStop)
      Tvlisting.updateTrTagHeight(lastProgramme, height)

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

  @removeOutSideAreaProgramme:(table, areaStart, areaStop) ->
    for tr in table.children('tbody').children('tr')
      trStart = Number($(tr).attr("start"))
      trStop = Number($(tr).attr("stop"))
      if (trStart >= areaStart &&
         trStart < areaStop) ||
         (trStop > areaStart &&
         trStop < areaStop)
        Tvlisting.adjustProgrammeHeight($(tr), areaStart, areaStop)
        continue
      tr.remove()

  @setAllShowProgrammeClass: () ->
    trArray = $('tr[name=programme]')
    for tr in trArray
      $(tr).css("opacity", 1.0)

  @setShowProgrammeClass: (table, showProgrammeClass) ->
    if showProgrammeClass == ""
      return
    if table != null
      trArray = table.children('tbody').children('tr[name=programme]')
    else
      trArray = $('tr[name=programme]')

    for tr in trArray
      $(tr).css("opacity", 1.0)
      if showProgrammeClass == $(tr).children("td").attr("class")
        continue
      $(tr).css("opacity", 0.2)

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

    tr.dblclick ->
      if Tvlisting.showProgrammeClass != ""
        Tvlisting.showProgrammeClass = ""
        Tvlisting.setAllShowProgrammeClass()
      else
        Tvlisting.showProgrammeClass = $(@).children("td").attr("class")
        Tvlisting.setShowProgrammeClass( null, Tvlisting.showProgrammeClass)

    tr.hover ->
      $('#information_listing').show()
      $('#information_menu').hide()
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
    ,->
      $('#information_menu').show()
      $('#information_listing').hide()

    fontSize = Tvlisting.adjustProgrammeFontSize(height)
    value = "<td class='" + programme.category + "'>"
    value = value + "<div class='tvlisting' "
    value = value + "title='" + programme.title + "' "
    value = value + "style='font-size:" + fontSize + "px;' "
    value = value + ">"
    value = value + @adjustProgrammeTitle(programme.title, height)
    value = value + "</div>"
    value = value + "</td>"
    tr.html(value)
    return tr

  @createProgrammeTrArray:(programmes) ->
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

  @removeSameProgrammTrArray:(table, programmes) ->
    for programme in programmes
      Tvlisting.removeSameProgramm(table, programme.start, programme.stop)

  @removeSameProgramm:(table, start, stop) ->
    for tr in table.children('tbody').children('tr[name=programme]')
      trStart = Number($(tr).attr("start"))
      trStop = Number($(tr).attr("stop"))
      if trStart != start || trStop != start
        continue
      tr.remove()

  @prependLoadingTag:(table, start, stop) ->
    trTag = Tvlisting.createLoadingTrTag(start, stop)
    table.prepend(trTag)

  @appendLoadingTag:(table, start, stop) ->
    trTag = Tvlisting.createLoadingTrTag(start, stop)
    table.append(trTag)

  createListingTable:(tvlistingsId, channelname) ->
    tvlistingsTable = $("<table id='" + channelname + "' />")
    tvlistingsTable = tvlistingsTable.appendTo("#" + tvlistingsId)
    tvlistingsTable.addClass("""
                    table table-bordered table-condensed tvlisting
                    """)
    tvlistingsTable.css("width", "140px")
    tvlistingsTable.css("float", "left")

  createListingNameTable:(tvlistingNamesId, channelname) ->
    tvlistingNameTable = $("<table id='" + channelname + "'></table>")
    tvlistingNameTable = tvlistingNameTable.appendTo("#" + tvlistingNamesId)
    tvlistingNameTable.addClass("""
                       table table-bordered table-condensed channelname
                       """)
    tvlistingNameTable.append("<tr><td></td></tr>")

  ajaxSetChannelName : ->
    url = getJsonChannelNameURL(@channelname)
    jQuery.ajaxQueue({url:url,
    success:(channelName) =>
      td = @tvlistingNameTable.children('tbody').children('tr').children('td')
      td.text(channelName)
    })

  getTableStatus : ->
    @tvlistingsTable.attr("status")


  @setProgrammesCallBack:(table, programmes, displayStart, displayStop) ->
    if programmes.length <= 1
      return
    Tvlisting.removeSameProgrammTrArray(table, programmes)

    firstProgramme = Tvlisting.getTableFirstProgramme(table)
    if firstProgramme == null
      Tvlisting.appendProgrammes(table, programmes)
    else if programmes[0].start < Number(firstProgramme.attr("start"))
      Tvlisting.prependProgrammes(table, programmes)
    else
      Tvlisting.appendProgrammes(table, programmes)

  setProgrammes:(areaStart, areaStop) ->
    Tvlisting.removeOutSideAreaProgramme(@tvlistingsTable, areaStart, areaStop)
    Tvlisting.adjustFirstProgramme(@tvlistingsTable, areaStart, areaStop)
    Tvlisting.adjustLastProgramme(@tvlistingsTable, areaStart, areaStop)

    firstProgramme = Tvlisting.getTableFirstProgramme(@tvlistingsTable)
    lastProgramme = Tvlisting.getTableLastProgramme(@tvlistingsTable)
    if firstProgramme == null && lastProgramme == null
      Tvlisting.appendLoadingTag(@tvlistingsTable, areaStart, areaStop)
      @ajaxMergeProgrammes(areaStart, areaStop)
    if firstProgramme != null
      firstProgrammeStart = Number(firstProgramme.attr("start"))
      if areaStart < firstProgrammeStart
        Tvlisting.prependLoadingTag(@tvlistingsTable, areaStart, firstProgrammeStart)
        @ajaxMergeProgrammes(areaStart, firstProgrammeStart)
    if lastProgramme != null
      lastProgrammeStop = Number(lastProgramme.attr("stop"))
      if areaStop > lastProgrammeStop
        Tvlisting.appendLoadingTag(@tvlistingsTable, lastProgrammeStop, areaStop)
        @ajaxMergeProgrammes(lastProgrammeStop, areaStop)

  @mergeProgrammesCallBack:(table, programmes, start, stop) ->
    selector = 'tr[name="loading"][start="' + start + '"][stop="' + stop + '"]'
    loadingTr = table.children('tbody').children(selector)
    if loadingTr == null
      return
    if programmes.length is 0
      loadingTr.remove()
      return

    programmeTags = @createProgrammeTrArray(programmes)
    if programmeTags.length is 0
      return
    Tvlisting.adjustTrArrayHeight(programmeTags, start, stop)

    programmesFirstTime = programmeTags[0].attr("start")
    programmesLastTime = programmeTags[programmeTags.length-1].attr("stop")
    if start < programmesFirstTime
      spaceTag = Tvlisting.createSpaceTrTag(start, programmesFirstTime)
      programmeTags.unshift(spaceTag)
    if stop > programmesLastTime
      spaceTag = Tvlisting.createSpaceTrTag(programmesLastTime, stop)
      programmeTags.push(spaceTag)

    prevTr = loadingTr.prev()
    if prevTr.attr("name") == "programme" &&
       prevTr.attr("start") == programmeTags[0].attr("start")
      prevTr.remove()
    nextTr = loadingTr.next()
    lastIndex = programmeTags.length - 1
    if nextTr.attr("name") == "programme" &&
       nextTr.attr("start") == programmeTags[lastIndex].attr("start")
      nextTr.remove()

    loadingTr.before(programmeTags)
    loadingTr.remove()

  ajaxMergeProgrammes:(start, stop) ->
    length =  convertMsToMin(stop - start)
    url = getJsonProgrammesURL(new Date(start), length, "GR", @channelname)

    Tvlisting.setTableStatus(@tvlistingsTable, "loading")
    jQuery.ajaxQueue( {url:url,
    context:{
      start: start,
      stop: stop,
      table: @tvlistingsTable
    },
    success:(programmes) ->
      Tvlisting.mergeProgrammesCallBack(this.table, programmes
      , this.start, this.stop)
      Tvlisting.setShowProgrammeClass(this.table, Tvlisting.showProgrammeClass)
    complete: ->
      Tvlisting.setTableStatus(this.table, "finish")
    })
