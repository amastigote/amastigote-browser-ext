# 1. load categories
# 2. choose one category to load its items
#    2.1. fetch last active category name and set it to active
#         ff api is a must in this case
#    2.2. set the first category to active

currentPage = 0
currentCategory = undefined
filteredTags = []

urlString = window.location.href
urlObject = new URL(urlString)

#noinspection SpellCheckingInspection
window.onerror = (errorMessage, scriptURI, lineNumber, columnNumber, error) ->
  $('#errMessage').text(errorMessage)
  $('#errLocation').text("#{scriptURI}:#{lineNumber}:#{columnNumber}")
  $('#errObject').text(JSON.stringify(error))
  $('#buttonGithubIssue').click ->
    window.open 'https://github.com/amastigote/amastigote-browser-ext/issues'
  $('#errorModal').modal
    show: true

#noinspection JSUnresolvedVariable
@server = unescape(urlObject.searchParams.get('server'))
#noinspection JSUnresolvedVariable
@port = unescape(urlObject.searchParams.get('port'))

if (!@server && !@port)
  throw "server or port is not defined in url"

loadCategories = (
  categoryContainer
  container
  btnPre
  btnSuc
  btnFilter
  pageIndicator
  inputTags
) ->
  get_category((result) ->
    categoryContainer.empty()
    if (result['stat'] == Status.COMPLETE)
      for item in result['obj']
        categoryContainer.append(generateItem(item))
      # FIXME we use method 2.2 to active a category
      if result['obj'].length > 0
        currentCategory = unescape(result['obj'][0]['name'])
        bindCategoryListeners(
          categoryContainer
          container
          btnPre
          btnSuc
          btnFilter
          pageIndicator
          inputTags
        )
        loadItems(
          {
            page: 0
            category: escape(currentCategory)
          }
          container
          btnPre
          btnSuc
          btnFilter
          pageIndicator
          inputTags
        )
      else
        categoryContainer.append("<a href='#' class='list-group-item list-group-item-action disabled' style='background-color:rgba(0,0,0,.075)'>暂无分类</a>")
        container.append("<tr style='font-size: 15px'><td colspan='4' style='color: #858D95'>暂无结果</td></tr>")
    else if (result['stat'] == Status.ERROR)
      container.append("<tr style='font-size: 15px'><td colspan='4' style='color: #858D95'>暂无结果</td></tr>")
  )

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
    container.empty()
    if (result['stat'] == Status.COMPLETE)
      currentPage = result['obj']['currentPage']
      btnPre.attr('disabled', result['obj']['isFirst'])
      btnSuc.attr('disabled', result['obj']['isLast'])
      pageIndicator.text(currentPage)
      for item in result['obj']['items']
        container.append(generateRow(item))
      bindRowListeners(inputTags, btnFilter)
      window.scrollTo(0, 0)
    else
      if (result['stat'] == Status.ERROR)
        btnPre.attr('disabled', true)
        btnSuc.attr('disabled', true)
        container.append("<tr style='font-size: 15px'><td colspan='4' style='color: #858D95'>暂无结果</td></tr>")
    pageIndicator.closest('div').css('visibility', 'visible')
  )

bindRowListeners = (inputTags, btnFilter) ->
  $('.editHref').click (e) ->
    e.preventDefault()
    showEditModal(this)
    false
  $('.tagHref').click ->
    inputTags.val($(this.childNodes[0]).text())
    btnFilter.trigger('click')

bindCategoryListeners = (
  categoryContainer
  container
  btnPre
  btnSuc
  btnFilter
  pageIndicator
  inputTags
) ->
  # TODO
  for item in categoryContainer.children()
    $(item).removeClass('active')
    if (currentCategory == item.text)
      $(item).addClass('active')
    $(item).click ->
      console.log this.text
      currentCategory = this.text
      for item0 in categoryContainer.children()
        $(item0).removeClass('active')
        if (currentCategory == item0.text)
          $(item0).addClass('active')
      loadItems(
        {
          page: 0
          category: escape(currentCategory)
        }
        container
        btnPre
        btnSuc
        btnFilter
        pageIndicator
        inputTags
      )

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
  categoryContainer = $('#category-container')

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

  #  loadItems(
  #    {page: 0}
  #    container
  #    btnPre
  #    btnSuc
  #    btnFilter
  #    pageIndicator
  #    inputTags)
  loadCategories(
    categoryContainer
    container
    btnPre
    btnSuc
    btnFilter
    pageIndicator
    inputTags
  )

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

@generateItem = (item) ->
  "<a href='#' class='list-group-item list-group-item-action'>#{escapeChars(unescape(item['name']))}</a>"
