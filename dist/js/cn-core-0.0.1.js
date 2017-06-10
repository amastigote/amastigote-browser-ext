var create = function (item, server_url, success_callback) {
    general_query(
        JSON.stringify(item),
        "https://localhost:8443/item",
        "POST",
        success_callback
    );
};

var update = function (item, server_url, success_callback) {
    general_query(
        JSON.stringify(item),
        "https://localhost:8443/item",
        "PUT",
        success_callback
    );
};

var remove = function (item, server_url, success_callback) {
    general_query(
        JSON.stringify(item),
        "https://localhost:8443/item",
        "DELETE",
        success_callback
    );
};

var get_item = function (item, server_url, success_callback) {
    general_query(
        item,
        "https://localhost:8443/item",
        "GET",
        success_callback
    );
};

var general_query = function (item, server_url, query_method, success_callback) {
    $.ajax({
        type: query_method,
        url: server_url,
        data: item,
        contentType: "application/json",
        dataType: "json",
        success: success_callback,
        error: function (request, status) {
            // todo
        }
    });
};

var get_tags = function (tag_serial, server_url, success_callback) {
    general_query(
        tag_serial,
        "https://localhost:8443/tag",
        "GET",
        success_callback
    );
};

var check_connection = function (server_url) {

};
