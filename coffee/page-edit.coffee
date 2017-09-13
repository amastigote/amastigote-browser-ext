titleInputModal = $('#modalInputTitle')
urlInputModal = $('#modalInputUrl')
tagsInputModal = $('#modalInputTags')
removeBtnModal = $('#editModalBtnRemove')
submitBtnModal = $('#editModalBtnSubmit')
categorySltModal = $('#modalSelectCategory')

currentRow = null

editModal = $('#editModal')

editModal.on('hidden.bs.modal', ->
  titleInputModal.val ''
  urlInputModal.val ''
  tagsInputModal.val ''
)

@showEditModal = (p0, p1) ->
  selectedCategory = p0.getAttribute('itemprop')
  getTags((result) ->
    split = (val) ->
      val.split(/,\s*/)

    extractLast = (term) ->
      split(term).pop()

    $('#modalInputTags').autocomplete({
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

  currentRow = p0.closest('tr')
  title = currentRow.childNodes[1].childNodes[0].text
  url = currentRow.childNodes[1].childNodes[0].getAttribute('href')
  spans = currentRow.childNodes[2].childNodes
  if spans.length == 0
    tags = ''
  else
    tags = ($(spans.item(i)).text() for i in [0..spans.length - 1] when $(spans.item(i).childNodes[0]).is 'span').join(', ')

  categorySltModal.empty()
  for e in p1
    itemHtml = "<option>#{e}</option>"
    if (e == selectedCategory)
      itemHtml = $($.parseHTML(itemHtml)).prop('selected', 'selected')
    categorySltModal.append(itemHtml)

  titleInputModal.val title
  urlInputModal.val url
  tagsInputModal.val tags

  editModal.modal
    show: true

submitBtnModal.click ->
  update collectItem(), (result) ->
    if result['stat'] == Status.COMPLETE
      location.reload()

removeBtnModal.click ->
  remove collectItem(), (result) ->
    if result['stat'] == Status.COMPLETE
      location.reload()

collectItem = ->
  title: escape(titleInputModal.val())
  url: urlInputModal.val()
  tags: tagsInputModal.val().replace(/[， 、]/g, ',').split(',').map((e) ->
    e.trim()
  ).filter((e) ->
    e != ''
  ).map((e) ->
    escape e
  )
  categoryName: escape categorySltModal.children(":selected").text()
