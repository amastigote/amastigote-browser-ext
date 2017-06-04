var add_btn = $('#btn_add');
var update_btn = $('#btn_update');
var delete_btn = $('#btn_delete');
var title_input = $('#input_title');
var url_input = $('#input_url');
var tag_input = $('#input_tag');
var querying = browser.tabs.query({ currentWindow: true, active: true });

querying.then(function (tabs) {
    if (tabs[0]) {
        title_input.val(tabs[0].title);
        url_input.val(tabs[0].url);
    }
});

add_btn.click(function () {
    change_buttons_clickability(false);
    create(collect_item(), "https://localhost:8443/item", function (result) {
        translate_action_result(result);
        change_buttons_clickability(true);
    });
});

var change_buttons_clickability = function (clickable) {
    add_btn.prop('disabled', !clickable);
};

var collect_item = function () {
    return {
        name: escape(title_input.val()),
        url: url_input.val(),
        /*
         todo tag cannot be empty
         */
        tag: tag_input.val().split(",").map(function (e) { return escape(e.trim()); }),
        auto_add_tag: true
    };
}

$(document).ready(function () {
    get_item({ url: url_input.val() }, "", function (result) {
        if (result.code === 700) {
            add_btn.prop('disabled', true);
            title_input.val(result.object.name);
            // tag_input.val(result.object.tag);
            console.log(result.tag);
        }
        else if (result.code === 800) {
            update_btn.prop('disabled', true);
            delete_btn.prop('disabled', true);
        }
    });
});
