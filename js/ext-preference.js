var server_input = $('#input_server');
var port_input = $('#input_port');
var save_button = $('#buttonSave');
var clear_button = $('#buttonClear');
var github_button = $('#buttonGithub');
var saveHint = $('#saveHint');

browser.storage.local
    .get(['cnServer', 'cnPort'])
    .then(function (result) {
        if (result['cnServer'] && result['cnServer'] !== '')
            server_input.val(result['cnServer']);
        if (result['cnPort'] && result['cnPort'] !== '')
            port_input.val(result['cnPort']);
    });

save_button.click(function () {
    browser.storage.local.set({
        cnServer: server_input.val().trim(),
        cnPort: port_input.val().trim()
    });
    saveHint.text('All preferences saved.');
    setTimeout(function () {
        location.reload();
    }, 1000);
});

clear_button.click(function () {
    server_input.val('');
    port_input.val('');
});

github_button.click(function () {
    window.open("https://github.com/amastigote");
});