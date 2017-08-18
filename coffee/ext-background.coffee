update_icon = (has_color, tab_id) ->
  browser.browserAction.setIcon
    path: if has_color then 48: '../pic/cn_1.png' else 48: '../pic/cn_0.png'
    tabId: tab_id

checkCurrentPage = (tab) ->
  get_item { url: tab.url }, (result) ->
    if result['stat'] == Status.COMPLETE
      update_icon true, tab.id
    else if result['stat'] == Status.ERROR
      update_icon false, tab.id

updateActiveTab = ->
  browser.tabs.query(
    active: true
    currentWindow: true).then (tabs) ->
      if tabs[0]
        checkCurrentPage tabs[0]

updateTags = (result) ->
  if result['stat'] == Status.COMPLETE
    browser.storage.local.set
      serial: result['msg']
      tags: result['obj']

fetchTagStat = ->
  tagSerial = browser.storage.local.get('serial')
  tagSerial.then (result) ->
    get_tags result, updateTags

browser.tabs.onUpdated.addListener updateActiveTab
browser.tabs.onActivated.addListener updateActiveTab
fetchTagStat()
setInterval (->
  fetchTagStat()
), 60000
