$(document).ready(function() {

  $("#enable_event_psc_ideal_date").click(function() {
    msg = "Updating the ideal date should only be performed by System Administrators " +
          "and under the rarest of circumstances.\nAltering the event ideal date might " +
          "break the event association in PSC."
    alert(msg);
    $("#event_psc_ideal_date").removeAttr('disabled');
    $('#disable_event_psc_ideal_date').show();
    $('#enable_event_psc_ideal_date').hide();
  });

  $("#disable_event_psc_ideal_date").click(function() {
    $("#event_psc_ideal_date").attr('disabled','disabled');
    $('#enable_event_psc_ideal_date').show();
    $('#disable_event_psc_ideal_date').hide();
  });

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