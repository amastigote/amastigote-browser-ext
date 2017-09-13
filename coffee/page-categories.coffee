createModal = $('#add-category-modal')
createModalNameInput = $('#ac-modal-name-input')
createModalCreateButton = $('#ac-modal-create-button')
createListItem = $('#create-category-li')

createListItem.click (e) ->
  e.preventDefault()
  createModal.modal
    show: true
  false

createModal.on('hidden.bs.modal', ->
  createModalNameInput.val ''
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
  name: escape(createModalNameInput.val())
  newName: ''
