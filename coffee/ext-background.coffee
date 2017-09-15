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

#noinspection JSUnresolvedVariable
browser.tabs.onUpdated.addListener updateActiveTab
#noinspection JSUnresolvedVariable
browser.tabs.onActivated.addListener updateActiveTab
