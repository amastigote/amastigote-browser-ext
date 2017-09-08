__serverKey = 'cnServer'
__portKey = 'cnPort'

@Status =
  COMPLETE: 0x0
  ERROR: 0x1
  EXCEPTION: 0x2

@create = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), 'item', 'POST', success_callback

@update = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), 'item', 'PUT', success_callback

@remove = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), 'item', 'DELETE', success_callback

@get_item = (payload, success_callback) ->
  dispatchQuery payload, 'item', 'GET', success_callback

@get_tags = (tag_serial, success_callback) ->
  dispatchQuery tag_serial, 'tag', 'GET', success_callback

dispatchQuery = (payload, urlEndPoint, query_method, success_callback) ->
  # When in page mode, server and port are available as global vars, fetch directly
  if (@server && @port)
    generalQuery(payload, urlEndPoint, query_method, success_callback, server, port)
  # When in panel mode, use an async way to fetch server and port from browser storage
  else if (browser)
    browser.storage.local.get([
      __serverKey
      __portKey
    ]).then (result) ->
      if result[__serverKey] != undefined and result[__portKey] != undefined
        server = result[__serverKey]
        port = result[__portKey]
        generalQuery(payload, urlEndPoint, query_method, success_callback, server, port)

generalQuery = (payload, urlEndPoint, query_method, success_callback, server, port) ->
  $.ajax
    type: query_method
    url: "http://#{server}:#{port}/#{urlEndPoint}"
    data: payload
    contentType: 'application/json'
    dataType: 'json'
    crossDomain: true
    crossOrigin: true
    success: success_callback