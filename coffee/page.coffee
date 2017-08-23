currentPage = 0
filteredTags = []

urlString = window.location.href
urlObject = new URL(urlString)

@server = urlObject.searchParams.get('server')
@port = urlObject.searchParams.get('port')

loadItems = (payload
  container
  btnPre
  btnSuc
  btnFilter
  pageIndicator
  inputTags) ->
  pageIndicator.closest('div')
    .css('visibility', 'hidden')
  listItems(payload, (result) ->
    if (result['stat'] == Status.COMPLETE)
      currentPage = result['obj']['currentPage']
      btnPre.attr('disabled', result['obj']['isFirst'])
      btnSuc.attr('disabled', result['obj']['isLast'])
      pageIndicator.text(currentPage)
      container.empty()
      for item in result['obj']['items']
        container.append(generateRow(item))
      bindRowListeners(inputTags, btnFilter)
      window.scrollTo(0, 0)
    else
      if (result['stat'] == Status.ERROR)
        btnPre.attr('disabled', true)
        btnSuc.attr('disabled', true)
        container.empty()
        container.append("<tr style='font-size: 15px'><td colspan='4'>无结果</td></tr>")
    pageIndicator.closest('div')
      .css('visibility', 'visible')
  )

bindRowListeners = (inputTags, btnFilter) ->
  $('.editHref').click ->
    showEditModal(this)
  $('.tagHref').click ->
    inputTags.val($(this.childNodes[0]).text())
    btnFilter.trigger('click')

packFilterParam = (rawVal, page) ->
  filteredTags = rawVal
    .replace(/[， 、]/g, ',')
    .split(',')
    .map((e) -> e.trim())
    .filter((e) -> e != '')
    .map((e) -> escape(e))

  page: page
  tag: filteredTags

$ ->
  container = $('#tableBody')
  btnPre = $('.btnPre')
  btnSuc = $('.btnSuc')
  pageIndicator = $('.pageIndicator')
  btnFilter = $('#btnFilter')
  btnClear = $('#btnClear')
  inputTags = $('#filterByTags')

  btnPre.click(-> loadItems(
    packFilterParam(filteredTags, currentPage - 2)
    container
    btnPre
    btnSuc
    btnFilter
    pageIndicator
    inputTags))

  btnSuc.click(-> loadItems(
    packFilterParam(filteredTags, currentPage)
    container
    btnPre
    btnSuc
    btnFilter
    pageIndicator
    inputTags))

  btnFilter.click(->
    loadItems(
      packFilterParam(inputTags.val(), 0)
      container
      btnPre
      btnSuc
      btnFilter
      pageIndicator
      inputTags))

  btnClear.click(->
    inputTags.val('')
    btnFilter.trigger('click')
  )

  inputTags.val('')
  loadItems(
    {page: 0}
    container
    btnPre
    btnSuc
    btnFilter
    pageIndicator
    inputTags)

  getTags((result) ->
    new Awesomplete(
      document.getElementById('filterByTags')
      {
        list: result['obj'].map((e) -> escapeChars(unescape(e.trim())))
        filter: (text, input) ->
          Awesomplete.FILTER_CONTAINS(text, input.match(/[^,]*$/)[0])
        item: (text, input) ->
          Awesomplete.ITEM(text, input.match(/[^,]*$/)[0])
        replace: (text) ->
          before = this.input.value.match(/^.+,\s*|/)[0]
          this.input.value = before + text + ", "
        minChars: 1
        maxItems: 5
        autoFirst: true
      })
  )

escapeChars = (string) ->
  string
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

@generateRow = (item) ->
  tagsBadges = item['tags'].map((e) ->
    "<a class='tagHref' href='#'><span class='badge badge-primary' style='font-size: 12px; vertical-align: middle'>\
    #{escapeChars(unescape(e['name']))}</span></a>")
    .join('&nbsp;')

  "<tr><td style='vertical-align: middle'>#{item['id']}</td><td style='vertical-align: middle; font-weight: bold; font-size: 15px'>\
   <a href='#{item['url']}'>#{escapeChars(unescape(item['title']))}</a>\
   </td><td style='vertical-align: middle'>#{tagsBadges}\
   </td><td style='font-size: 15px; vertical-align: middle'>\
   <a href='#' class='editHref'><i class='fa fa-pencil fa-1'></i>&nbsp;编辑</a></td></tr>"
