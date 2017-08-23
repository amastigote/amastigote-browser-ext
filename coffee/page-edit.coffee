titleInputModal = $('#modalInputTitle')
urlInputModal = $('#modalInputUrl')
tagsInputModal = $('#modalInputTags')
removeBtnModal = $('#editModalBtnRemove')
submitBtnModal = $('#editModalBtnSubmit')

currentRow = null

editModal = $('#editModal')
editModal.addClass('fade')

editModal.on('hidden.bs.modal', ->
  titleInputModal.val ''
  urlInputModal.val ''
  tagsInputModal.val ''
)

# fix Awesomplete's compatibility with Bootstrap
editModal.on('shown.bs.modal', ->
  width = $('#standard').width()
  tagsInputModal.css('width', "#{width}px")
)

@showEditModal = (p) ->
  getTags((result) ->
    new Awesomplete(
      document.getElementById('modalInputTags')
      {
        list: result['obj'].map((e) -> unescape(e.trim()))
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

  currentRow = p.closest('tr')
  title = currentRow.childNodes[1].childNodes[0].text
  url = currentRow.childNodes[1].childNodes[0].getAttribute('href')
  spans = currentRow.childNodes[2].childNodes
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
