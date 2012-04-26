$(function() {
  $('form.specimen_storage_form').live('submit', specimen_storage_dialog);

function specimen_storage_dialog() {
  var form = this;
  var submitInput = $(this).find("input[type='submit']")[0]
  $.ajax({
    type: $(form).attr('method'),
    url: $(form).attr('action'),
    data: $(form).serializeArray(),
    dataType: 'json',
    success: function(response) {
      $(submitInput).removeAttr('disabled');
      $(submitInput).val('Submit')
      if (response.specimen_storage) {
        var storage_container_id = response.specimen_storage.storage_container_id;
        var url = /specimen_storages/ + response.specimen_storage.id + ' form';
        $("#"+storage_container_id).load(url);
      } 
      if (response.sample_receipt_store) {
        var sample_id = response.sample_receipt_store.sample_id;
        var url = /sample_receipt_stores/ + response.sample_receipt_store.id + ' form';
        $("#"+response.sample_receipt_store.id).load(url);
      }
    },
    error: function(xhr, ajaxOptions, thrownError) {
      $(submitInput).removeAttr('disabled');
      $(submitInput).val('Submit')
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


$('.specimen_storage_edit').live('click', function(){ $(this).closest('form').closest('div').load($(this).attr('href') + ' form'); return false;});
});
i