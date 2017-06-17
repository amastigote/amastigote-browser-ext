var add_btn = $('#btn_add');
var update_btn = $('#btn_update');
var delete_btn = $('#btn_delete');
var browse_btn = $('#btn_browse');
var title_input = $('#input_title');
var url_input = $('#input_url');
var tag_input = $('#input_tag');
var img_settings = $('#img_settings');

browser.storage.local.get('tags').then(
    function (result) {
        if (result['tags'] === undefined)
            result = {tags: []};

        new Awesomplete(document.getElementById("input_tag"),
            {
                list: result.tags.map(function (e) {
                    return unescape(e);
                }),
                filter: function (text, input) {
                    return Awesomplete.FILTER_CONTAINS(text, input.match(/[^,]*$/)[0]);
                },

                item: function (text, input) {
                    return Awesomplete.ITEM(text, input.match(/[^,]*$/)[0]);
                },

                replace: function (text) {
                    var before = this.input.value.match(/^.+,\s*|/)[0];
                    this.input.value = before + text + ", ";
                },
                minChars: 1,
                maxItems: 2,
                autoFirst: true
            });
    }
);

browse_btn.click(function () {
    browser.storage.local.get(['cnServer', 'cnPort']).then(function (result) {
        browser.tabs.create({
            "url": '/amastigote-page/html/page.html?server=' + result['cnServer'] + '&port=' + result['cnPort']
        });
    });
});

add_btn.click(function () {
    add_btn.prop('disabled', true);
    create(collect_item(), function () {
        update_btn.prop('disabled', false);
        delete_btn.prop('disabled', false);
        browser.tabs.query({currentWindow: true, active: true})
            .then(function (tabs) {
                if (tabs[0]) {
                    update_icon(true, tabs[0].id)
                }
            });
    });
});

update_btn.click(function () {
    update_btn.prop('disabled', true);
    update(collect_item(), function () {
        update_btn.prop('disabled', false);
    });
});

delete_btn.click(function () {
    delete_btn.prop('disabled', true);
    remove(collect_item(), function () {
        add_btn.prop('disabled', false);
        update_btn.prop('disabled', true);
        browser.tabs.query({currentWindow: true, active: true})
            .then(function (tabs) {
                if (tabs[0]) {
                    update_icon(false, tabs[0].id);
                }
            });
    });
});

img_settings.click(function () {
   browser.runtime.openOptionsPage();
});

var update_icon = function (hasColor, tabId) {
    browser.browserAction.setIcon({
        path: hasColor ?
            {48: "../pic/cn_1.png"}
            :
            {48: "../pic/cn_0.png"},
        tabId: tabId
    });
};

var collect_item = function () {
    return {
        name: escape(title_input.val()),
        url: url_input.val(),
        tag: tag_input.val()
            .replace(new RegExp("，", 'g'), ",")
            .split(",")
            .map(function (e) {
                return e.trim();
            })
            .filter(function (e) {
                return e !== ''
            })
            .map(function (e) {
                return escape(e);
            }),
        auto_add_tag: true
    };
};

browser.tabs.query({currentWindow: true, active: true})
    .then(function (tabs) {
        if (tabs[0]) {
            title_input.val(tabs[0].title);
            url_input.val(tabs[0].url);

            get_item({url: url_input.val()}, function (result) {
                if (result.code === 700) {
                    add_btn.prop('disabled', true);
                    title_input.val(unescape(result.object.name));
                    tag_input.val(result.object.tag.map(function (e) {
                        return unescape(e.name);
                    }).join(", "));
                }
                else if (result.code === 800) {
                    update_btn.prop('disabled', true);
                    delete_btn.prop('disabled', true);
                }
            });
        }
    });
