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
  pageIndicator
  filteredTagsSpan) ->
  pageIndicator.closest('div')
    .css('visibility', 'hidden')
  listItems(payload, (result) ->
    filteredTagsSpan.empty()
    if filteredTags.length == 0
      filteredTagsSpan.append('<kbd>all</kbd>')
    else
      filteredTagsSpan.append("<kbd>#{filteredTags.join('</kbd> <kbd>')}</kbd>")
    if (result['stat'] == Status.COMPLETE)
      currentPage = result['obj']['currentPage']
      if (result['obj']['isFirst'])
        btnPre.attr('disabled', true)
      else
        btnPre.attr('disabled', false)
      if (result['obj']['isLast'])
        btnSuc.attr('disabled', true)
      else
        btnSuc.attr('disabled', false)
      pageIndicator.text(currentPage)
      container.empty()
      for item in result['obj']['items']
        container.append(generateRow(item))
      bindListenerForEditHref()
      window.scrollTo(0, 0)
    else
      if (result['stat'] == Status.ERROR)
        btnPre.attr('disabled', true)
        btnSuc.attr('disabled', true)
        container.empty()
        container.append("<tr style='font-size: 14px'><td colspan='4'>无结果</td></tr>")
    pageIndicator.closest('div')
      .css('visibility', 'visible')
  )

bindListenerForEditHref = ->
  $('.editHref').click ->
    showEditModal(this)

packageFilterParam = (rawVal, page) ->
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
  filteredTagsStrong = $('#filteredTags')

  btnPre.click(-> loadItems(
    {page: currentPage - 2}
    container
    btnPre
    btnSuc
    pageIndicator
    filteredTagsStrong))

  btnSuc.click(-> loadItems(
    {page: currentPage}
    container
    btnPre
    btnSuc
    pageIndicator
    filteredTagsStrong))

  loadItems(
    {page: 0}
    container
    btnPre
    btnSuc
    pageIndicator
    filteredTagsStrong)

  btnFilter.click(->
    loadItems(
      packageFilterParam(inputTags.val(), 0)
      container
      btnPre
      btnSuc
      pageIndicator
      filteredTagsStrong))

  btnClear.click(->
    inputTags.val('')
    btnFilter.trigger('click')
  )

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
    "<span class='badge badge-default' style='font-size: 12px;vertical-align: middle'>#{escapeChars(unescape(e['name']))}</span>")
    .join('&nbsp;')

  "<tr><td style='vertical-align: middle'>#{item['id']}</td><td style='vertical-align: middle'>\
   <a href='#{item['url']}'>#{escapeChars(unescape(item['title']))}</a>\
   </td><td style='vertical-align: middle'>#{tagsBadges}\
   </td><td style='font-size: 14px; vertical-align: middle'>\
   <a href='javascript:;' class='editHref'><i class='fa fa-pencil fa-1'></i>&nbsp;编辑</a></td></tr>"
