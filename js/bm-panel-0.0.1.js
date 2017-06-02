var add_btn = $('#btn_add');
var update_btn = $('#btn_update');
var delete_btn = $('#btn_delete');
var title_input = $('#input_title');
var url_input = $('#input_url');
var tag_input = $('#input_tag');
var querying = browser.tabs.query({currentWindow: true, active: true});

querying.then(function (tabs) {
    title_input.val(tabs[0].title);
    url_input.val(tabs[0].url);
});

add_btn.click(function () {
    var item = {
        name: title_input.val(),
        url: url_input.val(),
        /*
         todo tag cannot be empty
         */
        tag: tag_input.val(),
        auto_add_tag: true
    };
    change_buttons_clickability(false);
    create(item, "https://localhost:8443/item", function (result) {
        translate_action_result(result);
        change_buttons_clickability(true);
    });
});

var change_buttons_clickability = function(clickable) {
    add_btn.prop('disabled', !clickable);
};

$(document).ready(function () {
    get_item({url: url_input.val()}, "", function (result) {
        if (result.code === 700) {
            add_btn.prop('disabled', true);
        }
        else if (result.code === 800) {
            update_btn.prop('disabled', true);
            delete_btn.prop('disabled', true);
        }
    });
});
