var update_icon = function (has_color, tab_id) {
    browser.browserAction.setIcon({
        path: has_color ?
            { 48: "../pic/cn_1.png" }
            :
            { 48: "../pic/cn_0.png" },
        tabId: tab_id
    });
}

var check_current_page = function (tab) {
    get_item({ url: tab.url }, "", function (result) {
        if (result.code === 700) {
            update_icon(true, tab.id);
        } else if (result.code === 800) {
            update_icon(false, tab.id);
        }
    });
}

var update_active_tab = function () {
    browser.tabs.query({ active: true, currentWindow: true }).then(
        function (tabs) {
            if (tabs[0]) {
                check_current_page(tabs[0]);
            }
        }
    );
}

browser.tabs.onUpdated.addListener(update_active_tab);
browser.tabs.onActivated.addListener(update_active_tab);
