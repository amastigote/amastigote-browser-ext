add_btn = $('#btn_add')
update_btn = $('#btn_update')
delete_btn = $('#btn_delete')
browse_btn = $('#img_page')
settings_btn = $('#btn_settings')
title_input = $('#input_title')
url_input = $('#input_url')
tag_input = $('#input_tag')
img_settings = $('#img_settings')
categoryContainer = $('#select_category')

mask = $('#mask')
mask.css 'height', $(document).height()
mask.css 'width', $(document).width()

#noinspection JSUnresolvedVariable
browser.storage.local.get('tags').then (result) ->
  if result['tags'] == undefined
    result =
      tags: []

  split = (val) ->
    val.split(/,\s*/)

  extractLast = (term) ->
    split(term).pop()

  $('#input_tag').autocomplete({
    minLength: 1,
    source: (request, response) ->
      response($.ui.autocomplete.filter(
        result['tags'].map((e) -> escapeChars(unescape(e.trim()))), extractLast(request.term)));
  },
    focus: ->
      false
    select: (event, ui) ->
      terms = split(this.value)
      terms.pop()
      terms.push(ui.item.value)
      terms.push("");
      this.value = terms.join(", ")
      false
  );

browse_btn.click ->
  browser.storage.local.get([
    __serverKey
    __portKey
  ]).then (result) ->
    browser.tabs.create
      'url': '/html/page.html?server=' + escape(result[__serverKey]) + '&port=' + escape(result[__portKey])
    window.close()

add_btn.click ->
  mask.fadeIn()
  add_btn.prop 'disabled', true
  create collectItem(), (result) ->
    mask.fadeOut()
    if (result['stat'] == Status.COMPLETE)
      update_btn.prop 'disabled', false
      delete_btn.prop 'disabled', false
      #noinspection JSUnresolvedVariable
      browser.tabs.query(
        currentWindow: true
        active: true
      ).then (tabs) ->
        if tabs[0]
          updateIcon true, tabs[0].id
    else
      add_btn.prop 'disabled', false

update_btn.click ->
  mask.fadeIn()
  update_btn.prop 'disabled', true
  update collectItem(), (result) ->
    updatePanel(result)
    mask.fadeOut()
    update_btn.prop 'disabled', false

delete_btn.click ->
  mask.fadeIn()
  delete_btn.prop 'disabled', true
  remove collectItem(), ->
    mask.fadeOut()
    add_btn.prop 'disabled', false
    update_btn.prop 'disabled', true
    browser.tabs.query(
      currentWindow: true
      active: true
    ).then (tabs) ->
      if tabs[0]
        updateIcon false, tabs[0].id

img_settings.click ->
  browser.runtime.openOptionsPage()
  window.close()

settings_btn.click ->
  browser.runtime.openOptionsPage()
  window.close()

updateIcon = (hasColor, tabId) ->
  browser.browserAction.setIcon
    path: if hasColor then 48: '../pic/cn_1.png' else 48: '../pic/cn_0.png'
    tabId: tabId

collectItem = ->
  title: escape(title_input.val())
  url: url_input.val()
  tags: tag_input.val().replace(/[， 、]/g, ',').split(',').map((e) ->
    e.trim()
  ).filter((e) ->
    e != ''
  ).map((e) ->
    escape e
  )
  categoryName: escape categoryContainer.children(":selected").text()

escapeChars = (string) ->
  string
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

#noinspection JSUnresolvedVariable
browser.tabs.query(
  currentWindow: true
  active: true
).then (tabs) ->
  if tabs[0]
    url = tabs[0].url
    title_input.val removeSuffix(url, tabs[0].title)
    url_input.val url
    get_item {url: url_input.val()}, (result) ->
      if result['stat'] == Status.COMPLETE
        add_btn.prop 'disabled', true
        updatePanel(result)
        thisCategory = result['obj']['category']['name']
        loadCategories(categoryContainer, thisCategory)
      else if result['stat'] == Status.ERROR
        update_btn.prop 'disabled', true
        delete_btn.prop 'disabled', true
        loadCategories(categoryContainer)

updatePanel = (result) ->
  title_input.val escapeChars unescape(result['obj']['title'])
  tag_input.val result['obj']['tags'].map((e) ->
    escapeChars unescape e.name
  ).join(', ')

loadCategories = (container, thisCategory) ->
  get_category((result) ->
    for item in result['obj']
      itemHtml = "<option>#{unescape(item['name'])}</option>"
      if (item['name'] == thisCategory)
        itemHtml = $($.parseHTML(itemHtml)).prop('selected', 'selected')
      container.append(itemHtml)
    mask.fadeOut()
  )
