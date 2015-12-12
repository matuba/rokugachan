class @TimeTable
  @HEIGHT_UNIT_TIME  : 300

  constructor:(desNodeId, tablename, createTime, @timeInterval) ->
    @timeTable = createTimeTable(desNodeId, tablename, createTime.getTime(), timeInterval)

  createTimeTag = ( hour) ->
    tr = $('<tr/>')
    td = $('<td/>')
    small = $('<small/>')
    showTime = ("0" + hour).slice(-2)
    small.text(showTime)
    td.attr({"class":"timebetween" + showTime});
    tr.css("height", TimeTable.HEIGHT_UNIT_TIME + "px")
    small.appendTo(td)
    td.appendTo(tr)
    return tr

  createTimeTable = (desNodeId, tablename, start, timeInterval) ->
    timeTable = $("<table id='" + tablename + "'></table>").appendTo("#" + desNodeId)
    timeTable.addClass("table table-bordered table-condensed tvlistingTime")
    timeTable.css("width", "30px")
    timeTable.css("float", "left")

    stop = start + convertHourToMs(timeInterval)

    timeTable.attr({"start":start})
    timeTable.attr({"stop":stop})
    #append/prependメソッドがtableタグ内の値を使って追加するので
    #タグの要素に時間を追加しておく必要がある
    while start < stop
      timeTable.append( createTimeTag( new Date(start).getHours()))
      start = start + convertHourToMs(1)
    return timeTable

  heightAppendUnit : ->
    @timeInterval * TimeTable.HEIGHT_UNIT_TIME

  height : ->
    @timeTable.height()

  append : ->
    hour = @timeTable.children('tbody').children('tr:last').children('td').text()
    hour = parseInt(hour, 10)
    startDate = new Date();
    startDate.setHours(hour)
    start = startDate.getTime()
    for i in [0...@timeInterval]
      start = start + convertHourToMs(1)
      trTag = createTimeTag( new Date(start).getHours())
      @timeTable.append(trTag)
    @addDisplayAreaStopTime(@timeTable, @timeInterval)
    @heightAppendUnit()

  prepend : ->
    hour = @timeTable.children('tbody').children('tr:first').children('td').text()
    hour = parseInt(hour, 10)
    startDate = new Date();
    startDate.setHours(hour)
    start = startDate.getTime()
    for i in [0...@timeInterval]
      start = start - convertHourToMs(1)
      @timeTable.prepend( createTimeTag( new Date(start).getHours()))
    @subDisplayAreaStartTime(@timeTable, @timeInterval)
    @heightAppendUnit()

  dropFirst : ->
    for i in [0...@timeInterval]
      @timeTable.children('tbody').children('tr:first').remove()
    @addDisplayAreaStartTime(@timeTable, @timeInterval)
    @heightAppendUnit()

  dropLast : ->
    for i in [0...@timeInterval]
      @timeTable.children('tbody').children('tr:last').remove()
    @subDisplayAreaStopTime(@timeTable, @timeInterval)
    @heightAppendUnit()

  getStartTime : ->
    parseInt(@timeTable.attr("start"),10)

  getStopTime : ->
    parseInt(@timeTable.attr("stop"),10)

  getNowTime : ->
    parseInt(@timeTable.attr("start"),10) + convertHourToMs(@timeInterval)

  addDisplayAreaStartTime:(timeTable, timeInterval) ->
    start = parseInt(timeTable.attr("start"),10)
    start = start + convertHourToMs(timeInterval)
    timeTable.attr({"start":start})

  subDisplayAreaStartTime:(timeTable, timeInterval) ->
    start = parseInt(timeTable.attr("start"),10)
    start = start - convertHourToMs(timeInterval)
    timeTable.attr({"start":start})

  addDisplayAreaStopTime:(timeTable, timeInterval) ->
    stop = parseInt(timeTable.attr("stop"),10)
    stop = stop + convertHourToMs(timeInterval)
    timeTable.attr({"stop":stop})

  subDisplayAreaStopTime:(timeTable, timeInterval) ->
    stop = parseInt(timeTable.attr("stop"),10)
    stop = stop - convertHourToMs(timeInterval)
    timeTable.attr({"stop":stop})
