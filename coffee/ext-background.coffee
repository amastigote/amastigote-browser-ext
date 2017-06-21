update_icon = (has_color, tab_id) ->
  browser.browserAction.setIcon
    path: if has_color then 48: '../pic/cn_1.png' else 48: '../pic/cn_0.png'
    tabId: tab_id

check_current_page = (tab) ->
  get_item { url: tab.url }, (result) ->
    if result.code == 700
      update_icon true, tab.id
    else if result.code == 800
      update_icon false, tab.id

update_active_tab = ->
  browser.tabs.query(
    active: true
    currentWindow: true).then (tabs) ->
      if tabs[0]
        check_current_page tabs[0]


update_tags = (result) ->
  if result.code == 751
    browser.storage.local.set
      tag_serial: result.message
      tags: result.object

browser.tabs.onUpdated.addListener update_active_tab
browser.tabs.onActivated.addListener update_active_tab
setInterval (->
  tag_serial = browser.storage.local.get('tag_serial')
  tag_serial.then (result) ->
    get_tags result, update_tags
), 30000