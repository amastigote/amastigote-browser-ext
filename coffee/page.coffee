currentPage = 0
filteredTags = []

urlString = window.location.href
urlObject = new URL(urlString)

#noinspection SpellCheckingInspection
window.onerror = (errorMessage, scriptURI, lineNumber, columnNumber, error) ->
  $('#errMessage').text(errorMessage)
  $('#errLocation').text("#{scriptURI}:#{lineNumber}:#{columnNumber}")
  $('#errObject').text(JSON.stringify(error))
  $('#errorModal').modal
    show: true

#noinspection JSUnresolvedVariable
@server = urlObject.searchParams.get('server')
#noinspection JSUnresolvedVariable
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
  $('.editHref').click (e) ->
    e.preventDefault()
    showEditModal(this)
    false
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

  $('.form-inline').submit (e) ->
    e.preventDefault();
    btnFilter.trigger('click')
    false

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
    split = (val) ->
      val.split(/,\s*/)

    extractLast = (term) ->
      split(term).pop()

    $('#filterByTags').autocomplete({
      minLength: 1,
      source: (request, response) ->
        response($.ui.autocomplete.filter(
          result['obj'].map((e) -> escapeChars(unescape(e.trim()))), extractLast(request.term)));
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
  )

@escapeChars = (string) ->
  string
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

@generateRow = (item) ->
  tagsBadges = item['tags'].map((e) ->
    "<a class='tagHref' href='#'><span class='badge badge-dark' style='font-size: 11px; vertical-align: middle'>\
    #{escapeChars(unescape(e['name']))}</span></a>")
    .join('&nbsp;')

  "<tr><td style='vertical-align: middle'>#{item['id']}</td><td style='vertical-align: middle; font-weight: bold; font-size: 15px'>\
   <a href='#{item['url']}'>#{escapeChars(unescape(item['title']))}</a>\
   </td><td style='vertical-align: middle'>#{tagsBadges}\
   </td><td style='font-size: 13px; vertical-align: middle'>\
   <a href='#' class='editHref'><i class='fa fa-pencil fa-1'></i>&nbsp;编辑</a></td></tr>"
