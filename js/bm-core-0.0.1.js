var create = function (item, server_url, success_method) {
    general_query(item, server_url, "POST", success_method);
};

var update = function (item, server_url, success_method) {
    general_query(item, server_url, "PUT", success_method);
};

var remove = function (item, server_url, success_method) {
    general_query(item, server_url, "DELETE", success_method);
};

var get_item = function (item, server_url, success_method) {
    general_query(item, server_url, "GET", success_method);
};

var general_query = function (item, server_url, query_method, success_method) {
    $.ajax({
        type: query_method,
        url: "https://localhost:8443/item",
        data: item,
        dataType: "json",
        success: success_method,
        error: function (request, status) {
            // todo
            change_buttons_clickability(true);
        }
    });
};

var get_tags = function (server_url) {

};

var check_connection = function (server_url) {

};

var translate_action_result = function (error_result) {
    console.log(error_result);
    console.log(action_code[error_result.code]);
};
