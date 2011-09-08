NCSCore.UI.Participants = function (config) {
  
  var onsuccess = function(data) {
    var participant_id = data.id;
    var url = "/participants/" + participant_id + "/schedule";
    $.get(url, null, function (response) {
      $('div#participant_schedule_' + participant_id).replaceWith(response);
    });
  };
  
  var onerror = function(data) {
    var participant_id = data["id"];
    $('div#participant_schedule_' + participant_id).append("<div class='psc_error'>" + data.errors + "</div>");
  };

  $('.register_participant_with_psc').die('click');
  $('.register_participant_with_psc').live('click', function(e) {
    stop_default_action(e);
    $.ajax({
      type: 'POST',
      url: $(this).attr('action'),
      data: $(this).serializeArray(),
      dataType: 'json',
      success: function(data) {
        onsuccess(data);
      },
      error: function(jqXHR, textStatus, errorThrown) {
        onerror($.parseJSON(jqXHR.responseText));
      }
    });
  });
}