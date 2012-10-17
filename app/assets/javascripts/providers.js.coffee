$(document).ready ->

  $('#details_show').click ->
    $('#details').show();
    $('#details_show').hide();

  $('#details_hide').click ->
    $('#details').hide();
    $('#details_show').show();
