titleInputModal = $('#modalInputTitle')
urlInputModal = $('#modalInputUrl')
tagsInputModal = $('#modalInputTags')
removeBtnModal = $('#editModalBtnRemove')
submitBtnModal = $('#editModalBtnSubmit')

currentRow = null

editModal = $('#editModal')

editModal.on('hidden.bs.modal', ->
  titleInputModal.val ''
  urlInputModal.val ''
  tagsInputModal.val ''
)

@showEditModal = (p) ->
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

  currentRow = p.closest('tr')
  title = currentRow.childNodes[1].childNodes[0].text
  url = currentRow.childNodes[1].childNodes[0].getAttribute('href')
  spans = currentRow.childNodes[2].childNodes
  if spans.length == 0
    tags = ''
  else
    tags = ($(spans.item(i)).text() for i in [0..spans.length - 1] when $(spans.item(i).childNodes[0]).is 'span').join(', ')

  editModal.modal
    show: true
    backdrop: 'static'

  titleInputModal.val title
  urlInputModal.val url
  tagsInputModal.val tags

submitBtnModal.click ->
  update collectItem(), (result) ->
    editModal.modal 'hide'
    $(currentRow).html $($.parseHTML(generateRow(result['obj']))).html()
    $(currentRow).click(->
      showEditModal(this)
    )

removeBtnModal.click ->
  remove collectItem(), ->
    editModal.modal 'hide'
    $(currentRow).hide()

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
