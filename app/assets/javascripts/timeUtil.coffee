
@convertHourToMs = (hour) ->
  hour * 60 * 60 * 1000

@convertMinToMs = (min) ->
  min * 60 * 1000

@convertMsToMin = (ms) ->
  (ms / 1000) / 60
