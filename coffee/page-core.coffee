@getTags = (successCallback) ->
  generalQuery(
    undefined
    'tag'
    'GET'
    successCallback)

@listItems = (payload, successCallback) ->
  generalQuery(
    payload
    'item/list'
    'GET'
    successCallback)

generalQuery = (payload, urlEndPoint, queryMethod, successCallback) ->
  $.ajax {
    type: queryMethod
    url: "http://#{server}:#{port}/#{urlEndPoint}"
    data: payload
    contentType: 'application/json'
    dataType: 'json'
    crossDomain: true
    success: successCallback
    crossOrigin: true
  }
