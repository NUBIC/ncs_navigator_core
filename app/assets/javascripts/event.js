$(document).ready(function() {

  $("#enable_event_date_attributes").click(function() {
    $("#event_event_end_date").removeAttr('disabled');
    $("#event_event_end_time").removeAttr('disabled');
    $('#disable_event_date_attributes').show();
    $('#enable_event_date_attributes').hide();
  });

  $("#disable_event_date_attributes").click(function() {
    $("#event_event_end_date").attr('disabled','disabled');
    $("#event_event_end_time").attr('disabled','disabled');
    $('#enable_event_date_attributes').show();
    $('#disable_event_date_attributes').hide();
  });

});