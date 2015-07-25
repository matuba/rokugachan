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
    #append/prependメソッドがtableタグ内の値を使って追加するので
    #タグの要素に時間を追加しておく必要がある
    stop = start + (timeInterval * 60 * 60 * 1000)
    while start < stop
      timeTable.append( createTimeTag( new Date(start).getHours()))
      start = start + (60 * 60 * 1000)
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
      start = start + (60 * 60 * 1000)
      @timeTable.append( createTimeTag( new Date(start).getHours()))
    @heightAppendUnit()

  prepend : ->
    hour = @timeTable.children('tbody').children('tr:first').children('td').text()
    hour = parseInt(hour, 10)
    startDate = new Date();
    startDate.setHours(hour)
    start = startDate.getTime()
    for i in [0...@timeInterval]
      start = start - (60 * 60 * 1000)
      @timeTable.prepend( createTimeTag( new Date(start).getHours()))
    @heightAppendUnit()

  dropFirst : ->
    for i in [0...@timeInterval]
      @timeTable.children('tbody').children('tr:first').remove()
    @heightAppendUnit()

  dropLast : ->
    for i in [0...@timeInterval]
      @timeTable.children('tbody').children('tr:last').remove()
    @heightAppendUnit()
