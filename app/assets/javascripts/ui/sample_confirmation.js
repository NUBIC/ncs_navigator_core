$(function() {
  addStyles()
});

function addStyles() {
  $(".sample_receipt_tabs").tabs().addClass('ui-tabs-vertical ui-helper-clearfix');
  $(".sample_receipt_tabs li").removeClass('ui-corner-top').addClass('ui-corner-left');
  
  $('.submit_confirmation').live('click', sample_confirmation_process);
  
  $(".edit_confirmation").live('click', 
  function(){
    $(this).closest('div').load($(this).attr('href') + ' form');
    return false;
  })  
  
  function sample_confirmation_process() {
    var form = $(this).closest('form'),
        div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
      type: $(form).attr('method'),
      url: $(form).attr('action'),
      data: $(form).serializeArray(),
      dataType: 'json',
      success: function(response) {
        var url = /sample_receipt_confirmations/ + response.sample_receipt_confirmation.id + ' form';
        $(div).load(url)
      },
      error: function(xhr, ajaxOptions, thrownError) {
        $(submitInput).removeAttr('disabled');
        $(submitInput).val('Submit')
        if ($('#errorExplanation').length) {
          $('#errorExplanation').remove() 
        }
        var errors = $.parseJSON(xhr.responseText);
        errorText = "<h2>There were errors with the submission:</h2><ul>";
        for (error in errors) {
            errorText += "<li>" + error + ': ' + errors[error] + "</li> ";
        }
        errorText += "</ul>";
        if (!$('#errorExplanation').length) {
            $(form).prepend('<div id="errorExplanation" class="errorExplanation"/>')
        };
        $('#errorExplanation').html(errorText);
      }
    });
    return false;
  }  
}