var create = function (item, success_callback) {
    general_query(
        JSON.stringify(item),
        "item",
        "POST",
        success_callback
    );
};

var update = function (item, success_callback) {
    general_query(
        JSON.stringify(item),
        "item",
        "PUT",
        success_callback
    );
};

var remove = function (item, success_callback) {
    general_query(
        JSON.stringify(item),
        "item",
        "DELETE",
        success_callback
    );
};

var get_item = function (item, success_callback) {
    general_query(
        item,
        "item",
        "GET",
        success_callback
    );
};

var get_tags = function (tag_serial, success_callback) {
    general_query(
        tag_serial,
        "tag",
        "GET",
        success_callback
    );
};

var general_query = function (item, urlEndPoint, query_method, success_callback) {
    browser.storage.local.get(['cnServer', 'cnPort']).then(
        function (result) {
            if (result['cnServer'] !== undefined && result['cnPort'] !== undefined) {
                var server = result['cnServer'];
                var port = result['cnPort'];
                $.ajax({
                    type: query_method,
                    url: "https://" + server + ":" + port + "/" + urlEndPoint,
                    data: item,
                    contentType: "application/json",
                    dataType: "json",
                    crossDomain: true,
                    crossOrigin: true,
                    success: success_callback,
                    error: function (request, status) {
                        // todo
                    }
                });
            }
        }
    );
};
