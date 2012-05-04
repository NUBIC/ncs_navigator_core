$(function() {
    var specimen_receive_dialog = function(url, title, success_url) {
        $("#popup_dialog").load(url).dialog({
            title: title,
            height: 650,
            width: 800,
            modal: true,
            buttons: {
                Save: function() {
                  var dlg = $(this)
                  var form = $('form', this);
                  $.ajax({
                    type: 'POST',
                    url: $(form).attr('action'),
                    data: $(form).serializeArray(),
                    dataType: 'json',
                    success: function(response) {
                      if (response.specimen_receipt) {
                        var specimen_id = response.specimen_receipt.specimen_id;
                        var url = /specimen_receipts/ + response.specimen_receipt.id + ' form';
                        $("#"+specimen_id).load(url);
                      } 
                      if (response.sample_receipt_store) {
                        var sample_id = response.sample_receipt_store.sample_id;
                        var url = /sample_receipt_stores/ + response.sample_receipt_store.id + '?receive=true form';
                        $("#"+sample_id).load(url);
                      }
                      
                      dlg.dialog('close')                  
                    },
                    error: function(xhr, ajaxOptions, thrownError) {
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
                },
                Cancel: function() {
                    $(this).dialog('close')
                }
            },
            close: function() {
                $(this).html('')
            }
        });
    }
    
    $(".datetime").live('mouseover',
    function() {
      $(this).datetimepicker({});
    });
    
    $('.time').live('mouseover',
    function() {
      $(this).timepicker({})
    })
         
    $('.specimen_sample_receive').live('click',
    function() {
        specimen_receive_dialog($(this).attr('href') + ' form', 'Biological Specimens / Environmental Samples Receiving Form', $(this).attr('rel'));
        return false;
    });
    
    $(".sample_receipt_edit").live('click', 
    function(){
      $(this).closest('div').load($(this).attr('href') + '?receive=true form');
      return false;
    })
    
    $('.specimen_receipt_edit').live('click', function(){
      $(this).closest('div').load($(this).attr('href') + ' form'); 
      return false;
    });
    
    $('.sample_receipt_store_update_receive').live('click', specimen_sample_receive_process);
    
    $('form.specimen_receipt_form input[type="submit"]').live('click', specimen_sample_receive_process);

    function specimen_sample_receive_process() {
      var form = $(this).closest('form');
      var submitInput = $(this)
      $.ajax({
        type: $(form).attr('method'),
        url: $(form).attr('action'),
        data: $(form).serializeArray(),
        dataType: 'json',
        success: function(response) {
            if (response.specimen_receipt) {
            var storage_container_id = response.specimen_receipt.storage_container_id;
            var specimen_id = response.specimen_receipt.specimen_id;
            var url = /specimen_receipts/ + response.specimen_receipt.id + ' form';
            $("#"+specimen_id).load(url);
          } 
          if (response.sample_receipt_store) {
            var sample_id = response.sample_receipt_store.sample_id;
            var url = /sample_receipt_stores/ + response.sample_receipt_store.id + '?receive=true form';
            $("#"+response.sample_receipt_store.sample_id).load(url);
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
});


