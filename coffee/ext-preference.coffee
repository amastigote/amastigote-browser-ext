server_input = $('#input_server')
port_input = $('#input_port')
save_button = $('#buttonSave')
clear_button = $('#buttonClear')
github_button = $('#buttonGithub')

browser.storage.local.get([
  'cnServer'
  'cnPort'
]).then (result) ->
  if result['cnServer'] and result['cnServer'] != ''
    server_input.val result['cnServer']
  if result['cnPort'] and result['cnPort'] != ''
    port_input.val result['cnPort']

save_button.tooltip
  template: '<div class="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
  title: '设置已保存'
  trigger: 'manual'
  placement: 'right'
save_button.click ->
  browser.storage.local.set
    cnServer: server_input.val().trim()
    cnPort: port_input.val().trim()
  save_button.tooltip 'show'
  setTimeout (->
    save_button.tooltip 'hide'
  ), 1000

clear_button.click ->
  server_input.val ''
  port_input.val ''

github_button.click ->
  window.open 'https://github.com/amastigote/amastigote-browser-ext'
