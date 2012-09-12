$(document).ready ->

  $('#provider_details_show').click ->
    $('#provider_details').show();
    $('#provider_details_show').hide();

  $('#provider_details_hide').click ->
    $('#provider_details').hide();
    $('#provider_details_show').show();
