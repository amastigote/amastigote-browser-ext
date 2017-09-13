createModal = $('#add-category-modal')
editModal = $('#edit-category-modal')
createModalNameInput = $('#ac-modal-name-input')
createModalCreateButton = $('#ac-modal-create-button')
editModalSubmitButton = $('#ec-modal-submit-button')
editModalDeleteButton = $('#ec-modal-delete-button')
editModalCategorySelect = $('#ec-modal-category-select')
editModalNameInput = $('#ec-modal-name-input')
createListItem = $('#create-category-li')
editListItem = $('#edit-category-li')

createListItem.click (e) ->
  e.preventDefault()
  createModal.modal
    show: true
  false

editListItem.click (e) ->
  e.preventDefault()
  get_category((result) ->
    for item in result['obj']
      itemHtml = "<option>#{item['name']}</option>"
      editModalCategorySelect.append(itemHtml)
  )
  editModal.modal
    show: true
  false

createModal.on('hidden.bs.modal', ->
  createModalNameInput.val ''
)

editModal.on('hidden.bs.modal', ->
  editModalNameInput.val ''
)

editModalDeleteButton.click ->
  editModalCategorySelect.removeClass('border-danger')
  remove_category(collectItemForEditModal(), (result) ->
    if result['stat'] == Status.COMPLETE
      location.reload()
    else if result['stat'] == Status.ERROR
      editModalCategorySelect.addClass('border-danger')
  )

editModalSubmitButton.click ->
  editModalNameInput.removeClass('border-danger')
  update_category(collectItemForEditModal(), (result) ->
    if result['stat'] == Status.COMPLETE
      editModalNameInput.addClass('border-success')
      setTimeout(
        () ->
          editModalNameInput.val ''
          location.reload()
        500
      )
    else if result['stat'] == Status.ERROR
      editModalNameInput.addClass('border-danger')
  )

createModalCreateButton.click ->
  createModalNameInput.removeClass('border-danger')
  createModalCreateButton.prop('disabled', true)
  create_category(collectItemForCreateModal(), (result) ->
    if result['stat'] == Status.ERROR
      createModalNameInput.addClass('border-danger')
      createModalCreateButton.prop('disabled', false)
    else if result['stat'] == Status.COMPLETE
      createModalNameInput.addClass('border-success')
      setTimeout(
        () ->
          createModalNameInput.val ''
          location.reload()
        500
      )
  )

collectItemForCreateModal = ->
  name: escape(createModalNameInput.val().trim())
  newName: ''

collectItemForEditModal = ->
  name: editModalCategorySelect.children(":selected").text()
  newName: editModalNameInput.val().trim()
