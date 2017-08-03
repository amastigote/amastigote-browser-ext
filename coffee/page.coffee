currentPage = 0
filteredTags = []

urlString = window.location.href
urlObject = new URL(urlString)

@server = urlObject.searchParams.get('server')
@port = urlObject.searchParams.get('port')

requestForEmailRegistration = (email, modalSpan) ->
  registerEmail(
    {mail: email}
    (result) ->
      modalSpan.removeClass()
      if (result.code == 770)
        modalSpan.addClass('text-primary')
        modalSpan.text('验证邮件已发送至您的邮箱')
      else if (result.code == 771)
        modalSpan.addClass('text-success')
        modalSpan.text('您已订阅过此文章列表')
      else if (result.code == 772)
        modalSpan.addClass('text-warning')
        modalSpan.text('已向您发送过邮件，请稍后再试')

      setTimeout(
        ->
          location.reload()
        1500
      )
  )

# SENT 770 / EMAIL REGISTERED 771 / EMAIL STILL NOT VALIDATED 772

loadItems = (payload
  container
  btnPre
  btnSuc
  pageIndicator
  filteredTagsSpan) ->
  listItems(payload, (result) ->
    filteredTagsSpan.empty()
    if filteredTags.length == 0
      filteredTagsSpan.append('<kbd>all</kbd>')
    else
      filteredTagsSpan.append("<kbd>#{filteredTags.join('</kbd> <kbd>')}</kbd>")
    if (result['code'] == 704)
      currentPage = result['object']['currentPage']
      if (result['object']['isFirst'])
        btnPre.attr('disabled', true)
      else
        btnPre.attr('disabled', false)
      if (result['object']['isLast'])
        btnSuc.attr('disabled', true)
      else
        btnSuc.attr('disabled', false)
      pageIndicator.text(currentPage)
      container.empty()
      for item in result['object']['bookMarkItems']
        container.append(generateRow(item))
      bindListenerForEditHref()
      window.scrollTo(0, 0)
    else
      if (result['code'] == 802)
        location.reload()
  )

bindListenerForEditHref = ->
  $('.editHref').click ->
    showEditModal(this)

packageFilterParam = (rawVal, page) ->
  filteredTags = rawVal
    .replace(new RegExp('，', 'g'), ',')
    .split(',')
    .map((e) -> e.trim())
    .filter((e) -> e != '')
    .map((e) -> escape(e))
  {
    page: page
    tag: filteredTags
  }

$ ->
  container = $('#tableBody')
  btnPre = $('.btnPre')
  btnSuc = $('.btnSuc')
  pageIndicator = $('.pageIndicator')
  btnFilter = $('#btnFilter')
  btnClear = $('#btnClear')
  inputTags = $('#filterByTags')
  filteredTagsStrong = $('#filteredTags')
  btnModal = $('#btnModal')
  inputModal = $('#modalInput')
  spanModal = $('#modalSpan')
  registerModal = $('#registerModal')

  $('#itemTable').stickyTableHeaders()

  registerModal.addClass('fade')

  registerModal.on('hidden.bs.modal', ->
    inputModal.val('')
    spanModal.text('')
    btnModal.removeAttr('disabled')
  )

  btnModal.click(->
    if (inputModal.val().trim().length != 0)
      btnModal.attr('disabled', true)
      requestForEmailRegistration(
        inputModal.val().trim()
        spanModal)
  )

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
        list: result['object'].map((e) -> unescape(e.trim()))
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

generateRow = (item) ->
  tagsBadges = item['tag'].map((e) ->
    "<span class=\"badge badge-default\">#{unescape(e['name'])}</span>")
    .join('&nbsp;')

  "<tr><td style='vertical-align: middle'>#{item['id']}</td><td style='vertical-align: middle'>\
   <a href='#{item['url']}'>#{unescape(item['name'])}</a>\
   </td><td style='vertical-align: middle'>#{tagsBadges}\
   </td><td style='font-size: 14px; vertical-align: middle'>\
   <a href='javascript:;' class='editHref'><i class='fa fa-pencil fa-1'></i> 编辑</a></td></tr>"
