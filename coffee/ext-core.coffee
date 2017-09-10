__serverKey = 'cnServer'
__portKey = 'cnPort'

__itemPath = 'item'
__tagPath = 'tag'
__categoryPath = 'category'

__CREATE = 'POST'
__FETCH = 'GET'
__UPDATE = 'PUT'
__REMOVE = 'DELETE'

@Status =
  COMPLETE: 0x0
  ERROR: 0x1
  EXCEPTION: 0x2

@create = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), __itemPath, __CREATE, success_callback

@update = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), __itemPath, __UPDATE, success_callback

@remove = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), __itemPath, __REMOVE, success_callback

@get_item = (payload, success_callback) ->
  dispatchQuery payload, __itemPath, __FETCH, success_callback

@create_category = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), __categoryPath, __CREATE, success_callback

@get_category = (success_callback) ->
  dispatchQuery undefined, __categoryPath, __FETCH, success_callback

@update_category = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), __categoryPath, __UPDATE, success_callback

@remove_category = (payload, success_callback) ->
  dispatchQuery JSON.stringify(payload), __categoryPath, __REMOVE, success_callback

@get_tags = (tag_serial, success_callback) ->
  dispatchQuery tag_serial, __tagPath, __FETCH, success_callback

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