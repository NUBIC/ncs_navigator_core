$(document).ready(function() {
  $('.surveyor_radio').parent().parent().append('<a class="reset-button">Reset</a>');

  $('.reset-button').click(function () {
      $('input[type="radio"]:checked','#'+$(this).data('question-id')).each(function () {
          $(this).prop('checked', false);
      }).trigger('change');
  });

  $('fieldset').each(function () {
      var qid = $(this).attr('id');
      $('.reset-button', $(this)).attr('data-question-id', qid);
  });
});
