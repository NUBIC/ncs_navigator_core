NCSCore.UI.Participants = function (config) {
  
  var onsuccess = function(data) {
    var participant_id = data.id;
    var url = "/participants/" + participant_id + "/schedule";
    $.get(url, null, function (response) {
      $('div#participant_schedule_' + participant_id).replaceWith(response);
    });
  };

  $('.register_participant_with_psc').live('click', function(e) {
    stop_default_action(e);
    $.ajax({
      type: 'POST',
      url: $(this).attr('action'),
      data: $(this).serializeArray(),
      dataType: 'json',
      success: function(response) {
        onsuccess(response);
      }
    });
  });
}