titleInputModal = $('#modalInputTitle')
urlInputModal = $('#modalInputUrl')
tagsInputModal = $('#modalInputTags')
removeBtnModal = $('#editModalBtnRemove')
submitBtnModal = $('#editModalBtnSubmit')

editModal = $('#editModal')
editModal.addClass('fade')

editModal.on('hidden.bs.modal', ->
  titleInputModal.val ''
  urlInputModal.val ''
  tagsInputModal.val ''
)

@showEditModal = (p) ->
  getTags((result) ->
    new Awesomplete(
      document.getElementById('modalInputTags')
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

  tds = p.closest('tr').childNodes
  title = tds[1].childNodes[0].text
  url = tds[1].childNodes[0].getAttribute('href')
  spans = tds[2].childNodes
  tags = ($(spans.item(i)).text() for i in [0..spans.length - 1] when $(spans.item(i)).is 'span').join(', ')

  editModal.modal
    show: true
    backdrop: 'static'

  # fix awesomplete's compatibility with jQuery
  editModal.on('shown.bs.modal', ->
    width = $('#standard').width()
    tagsInputModal.css('width', "#{width}px")
  )

  titleInputModal.val title
  urlInputModal.val url
  tagsInputModal.val tags

submitBtnModal.click ->
  update collectItem(), ->
    location.reload()

removeBtnModal.click ->
  remove collectItem(), ->
    location.reload()

collectItem = ->
  name: escape(titleInputModal.val())
  url: urlInputModal.val()
  tag: tagsInputModal.val().replace(new RegExp('，', 'g'), ',').split(',').map((e) ->
    e.trim()
  ).filter((e) ->
    e != ''
  ).map((e) ->
    escape e
  )
  auto_add_tag: true
