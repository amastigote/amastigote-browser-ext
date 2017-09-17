currentPage = 0
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

loadCategories = (categoryContainer
  container
  btnPre
  btnSuc
  btnFilter
  pageIndicator
  inputTags) ->
  get_category((result) ->
    categoryContainer.empty()
    if (result['stat'] == Status.COMPLETE)
      for item in result['obj']
        categoryContainer.append(generateItem(item))
      if result['obj'].length > 0
        bindCategoryListeners(
          unescape(result['obj'][0]['name'])
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
            categoryName: escape(unescape(result['obj'][0]['name']))
          }
          container
          btnPre
          btnSuc
          btnFilter
          pageIndicator
          inputTags
          categoryContainer
          unescape(result['obj'][0]['name'])
        )
      else
        categoryContainer.append("<a href='#' class='list-group-item list-group-item-action disabled' style='background-color:rgba(0,0,0,.075)'>暂无分类</a>")
        container.append("<tr style='font-size: 15px; height: 49px'><td colspan='4' style='color: #858D95'>暂无结果</td></tr>")
    else if (result['stat'] == Status.ERROR)
      container.append("<tr style='font-size: 15px; height: 49px'><td colspan='4' style='color: #858D95'>暂无结果</td></tr>")
  )

loadItems = (payload
  container
  btnPre
  btnSuc
  btnFilter
  pageIndicator
  inputTags
  categoryContainer
  category) ->
  pageIndicator.closest('div')
    .css('visibility', 'hidden')
  list_items(payload, (result) ->
    container.empty()
    if (result['stat'] == Status.COMPLETE)
      currentPage = result['obj']['currentPage']
      btnPre.attr('disabled', result['obj']['isFirst'])
      btnSuc.attr('disabled', result['obj']['isLast'])
      pageIndicator.text(currentPage)
      for item in result['obj']['items']
        container.append(generateRow(item, category))
      bindRowListeners(inputTags, btnFilter, categoryContainer)
    else
      if (result['stat'] == Status.ERROR)
        btnPre.attr('disabled', true)
        btnSuc.attr('disabled', true)
        container.append("<tr style='font-size: 15px; height: 49px'><td colspan='4' style='color: #858D95'>暂无结果</td></tr>")
    pageIndicator.closest('div').css('visibility', 'visible')
    rebindGlobalButtons(
      category
      categoryContainer
      container
      btnPre
      btnSuc
      btnFilter
      pageIndicator
      inputTags
    )
    $("html, body").animate({scrollTop: 0}, 500);
  )

bindRowListeners = (inputTags, btnFilter, categoryContainer) ->
  $('.editHref').click (e) ->
    e.preventDefault()
    showEditModal(this, categoryContainer.children().map((i, e) -> $(e).text()))
    false
  $('.tagHref').click (e) ->
    e.preventDefault()
    inputTags.val($(this.childNodes[0]).text())
    btnFilter.trigger('click')
    false

bindCategoryListeners = (selectedCategory
  categoryContainer
  container
  btnPre
  btnSuc
  btnFilter
  pageIndicator
  inputTags) ->
  for item in categoryContainer.children()
    $(item).removeClass('active')
    if (selectedCategory == item.text)
      $(item).addClass('active')
    $(item).click (e) ->
      e.preventDefault()
      currentPage = 0
      inputTags.val('')
      for item0 in categoryContainer.children() then $(item0).removeClass('active')
      $(this).addClass('active')
      selectedCategory = this.text
      loadItems(
        {
          page: 0
          categoryName: escape(this.text)
        }
        container
        btnPre
        btnSuc
        btnFilter
        pageIndicator
        inputTags
        categoryContainer
        selectedCategory
      )
    false

packFilterParam = (rawVal, page, category) ->
  filteredTags = rawVal
    .replace(/[， 、]/g, ',')
    .split(',')
    .map((e) -> e.trim())
    .filter((e) -> e != '')
    .map((e) -> escape(e))

  page: page
  tag: filteredTags
  categoryName: category

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
    e.preventDefault()
    btnFilter.trigger('click')
    false

  btnClear.click(->
    inputTags.val('')
    btnFilter.trigger('click')
  )

  inputTags.val('')

  loadCategories(
    categoryContainer
    container
    btnPre
    btnSuc
    btnFilter
    pageIndicator
    inputTags
  )

  get_tags((result) ->
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

@generateRow = (item, category) ->
  tagsBadges = item['tags'].map((e) ->
    "<a class='tagHref' href='#'><span class='badge badge-dark' style='font-size: 11px; vertical-align: middle'>\
    #{escapeChars(unescape(e['name']))}</span></a>")
    .join('&nbsp;')

  "<tr><td style='vertical-align: middle'>#{item['id']}</td><td style='vertical-align: middle; font-weight: bold; font-size: 15px'>\
   <a href='#{item['url']}'>#{escapeChars(unescape(item['title']))}</a>\
   </td><td style='vertical-align: middle'>#{tagsBadges}\
   </td><td style='font-size: 13px; vertical-align: middle'>\
   <a href='#' itemprop='#{category}' class='editHref'><i class='fa fa-pencil fa-1'></i>&nbsp;编辑</a></td></tr>"

@generateItem = (item) ->
  "<a href='#' class='list-group-item list-group-item-action'>#{escapeChars(unescape(item['name']))}</a>"

rebindGlobalButtons = (selectedCategory
  categoryContainer
  container
  btnPre
  btnSuc
  btnFilter
  pageIndicator
  inputTags) ->
  btnPre.unbind 'click'
  btnPre.click(-> loadItems(
    packFilterParam(filteredTags, currentPage - 2, selectedCategory)
    container
    btnPre
    btnSuc
    btnFilter
    pageIndicator
    inputTags
    categoryContainer
    selectedCategory
  ))

  btnSuc.unbind 'click'
  btnSuc.click(-> loadItems(
    packFilterParam(filteredTags, currentPage, selectedCategory)
    container
    btnPre
    btnSuc
    btnFilter
    pageIndicator
    inputTags
    categoryContainer
    selectedCategory
  ))

  btnFilter.unbind 'click'
  btnFilter.click(->
    loadItems(
      packFilterParam(inputTags.val(), 0, selectedCategory)
      container
      btnPre
      btnSuc
      btnFilter
      pageIndicator
      inputTags
      categoryContainer
      selectedCategory
    ))
