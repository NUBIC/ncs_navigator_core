$(document).ready ->
  $('.swap_2').hide();
  $('#swap_2').hide();
  $('#swap_1').click ->
    $('.swap_1').hide();
    $('#swap_1').hide();    
    $('.swap_2').show();
    $('#swap_2').show();

  $('#swap_2').click ->
    $('.swap_2').hide();
    $('#swap_2').hide();    
    $('.swap_1').show();
    $('#swap_1').show();


