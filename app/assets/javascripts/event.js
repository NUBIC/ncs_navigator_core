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

  $("#enable_event_type_code").click(function() {
    alert("Altering the event type might break the event association in PSC.")
    $("#event_event_type_code").removeAttr('disabled');
    $('#disable_event_type_code').show();    
    $('#enable_event_type_code').hide();
  });

  $("#disable_event_type_code").click(function() {
    $("#event_event_type_code").attr('disabled','disabled');
    $('#enable_event_type_code').show();
    $('#disable_event_type_code').hide();    
  });

  $("#enable_event_start_date").click(function() {
    alert("Altering the event start date might break the event association in PSC.")
    $("#event_event_start_date").removeAttr('disabled');
    $('#disable_event_start_date').show();
    $('#enable_event_start_date').hide();    
  });

  $("#disable_event_start_date").click(function() {
    $("#event_event_start_date").attr('disabled','disabled');
    $('#enable_event_start_date').show();
    $('#disable_event_start_date').hide();    
  });

});