class @TimeTable
  @TIME_BETWEEN : 4

  constructor:(tablename, tvlistingsId, createTime) ->
    @timeTable = @createTimeTable(tablename, tvlistingsId, createTime.getTime())

  createTimeTag : ( hour) ->
    tr = $('<tr/>')
    td = $('<td/>')
    small = $('<small/>')
    showTime = ("0" + hour).slice(-2)
    small.text(showTime)
    td.attr({"class":"timebetween" + showTime});
    tr.css("height", "300px")
    small.appendTo(td)
    td.appendTo(tr)
    return tr

  createTimeTable : (tablename, tvlistingsId, start) ->
    timeTable = $("<table id='" + tablename + "'></table>").appendTo("#" + tvlistingsId)
    timeTable.addClass("table table-bordered table-condensed tvlistingTime")
    timeTable.css("width", "30px")
    timeTable.css("float", "left")

    stop = start + (TimeTable.TIME_BETWEEN * 60 * 60 * 1000)
    while start < stop
      timeTable.append( @createTimeTag( new Date(start).getHours()))
      start = start + (60 * 60 * 1000)
    return timeTable

  appendTimeTable : ->
    hour = @timeTable.children('tbody').children('tr:last').children('td').text()

    hour = parseInt(hour, 10)
    startDate = new Date();
    startDate.setHours(hour)
    start = startDate.getTime()
    for i in [0...TimeTable.TIME_BETWEEN]
      start = start + (60 * 60 * 1000)
      @timeTable.append( @createTimeTag( new Date(start).getHours()))

  prependTimeTable : ->
    hour = @timeTable.children('tbody').children('tr:first').children('td').text()
    hour = parseInt(hour, 10)
    startDate = new Date();
    startDate.setHours(hour)
    start = startDate.getTime()
    for i in [0...TimeTable.TIME_BETWEEN]
      start = start - (60 * 60 * 1000)
      @timeTable.prepend( @createTimeTag( new Date(start).getHours()))

  dropFirstTimeTable : ->
    for i in [0...TimeTable.TIME_BETWEEN]
      @timeTable.children('tbody').children('tr:first').remove()

  dropLastTimeTable : ->
    for i in [0...TimeTable.TIME_BETWEEN]
      @timeTable.children('tbody').children('tr:last').remove()
