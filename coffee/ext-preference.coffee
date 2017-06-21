server_input = $('#input_server')
port_input = $('#input_port')
save_button = $('#buttonSave')
clear_button = $('#buttonClear')
github_button = $('#buttonGithub')
saveHint = $('#saveHint')

browser.storage.local.get([
  'cnServer'
  'cnPort'
]).then (result) ->
  if result['cnServer'] and result['cnServer'] != ''
    server_input.val result['cnServer']
  if result['cnPort'] and result['cnPort'] != ''
    port_input.val result['cnPort']

save_button.click ->
  browser.storage.local.set
    cnServer: server_input.val().trim()
    cnPort: port_input.val().trim()
  saveHint.text 'All preferences saved.'
  setTimeout (->
    location.reload()

  ), 1000

clear_button.click ->
  server_input.val ''
  port_input.val ''

github_button.click ->
  window.open 'https://github.com/amastigote'
