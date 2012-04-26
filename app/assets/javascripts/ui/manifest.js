NCSCore.UI.Manifest = function (config) {
  $('.specimen').live('change', click_radio)
  $('.sample').live('change', click_radio)

  function click_radio() {
    var elt_name = $(this).attr('value')
    // var params = "&offset=" + oState.pagination.recordOffset;
    // if (searchText !== "") {
    //     params += "&q=" + searchText;
    // }
    var url = "/manifest/process";
    var params = "&source=" + elt_name
    $.ajax({
      type: 'PUT',
      url: url,
      data: params,
      dataType: 'json',
      success: function(data) {
        onsuccess(data);
      },
      error: function(jqXHR, textStatus, errorThrown) {
        onerror($.parseJSON(jqXHR.responseText));
      }
    });
  };
}