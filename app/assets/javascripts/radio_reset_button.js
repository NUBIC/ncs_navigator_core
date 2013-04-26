$(document).ready(function() {
  $('.surveyor_radio').parent().parent().append('<a class="reset-button">Reset</a>');

  $('.reset-button').click(function () {
      $('#'+$(this).data('question-id') + ' input[type="radio"]:checked').prop('checked', false).trigger('change');
  });

  $(".reset-button").each(function() {
    $(this).data('question-id', $(this).parent().attr('id'));
  });

});
