$(function() {

  $('.specimen_ship_checkbox').live('click',
  function() {
    var atLeastOneIsChecked = $('#ship_specimens :checkbox:checked').length > 0;
    if (atLeastOneIsChecked) {
      $('#ship_samples :checkbox').attr("disabled", true)
      $('#ship_samples_btn').attr("disabled", true)
      $('#ship_samples :checkbox:checked').each( function() {
           this.checked = !this.checked;
      });
      $('#ship_specimens_btn').attr("disabled", false)
    } else {
      $('#ship_samples :checkbox').attr("disabled", false);
      $('#ship_samples_btn').attr("disabled", true)
      $('#ship_specimens_btn').attr("disabled", true)
    }
  })

  $('.sample_ship_checkbox').live('click',
  function() {
    var atLeastOneIsChecked = $('#ship_samples :checkbox:checked').length > 0;
    if (atLeastOneIsChecked) {
      $('#ship_specimens :checkbox').attr("disabled", true)
      $('#ship_specimens_btn').attr("disabled", true)
      $('#ship_specimens :checkbox:checked').each( function() {
           this.checked = !this.checked;
      });
      $('#ship_samples_btn').attr("disabled", false)
    } else {
      $('#ship_specimens :checkbox').attr("disabled", false);
      $('#ship_specimens_btn').attr("disabled", true)
      $('#ship_samples_btn').attr("disabled", true)
    }
  })

  $('.exit_and_no_refresh').live('click',
  function() {
    clearShipSelections();
  })
  
  $('.exit_and_refresh').live('click',
  function() {
    clearShipSelections();
    location.reload();
  })
  
  function clearShipSelections() {
    blockUnblockProcessingDiv(false, "")
    $(':submit').each( function() {
      $(this).attr("disabled", true)
    })
    $(':checkbox:checked').each( function() {
      this.checked = !this.checked;
    });
    $('#displaying').children().each(function(){$(this).remove()})
    $(':checkbox').attr("disabled", false)
  }

  //kak submittit' bez dannih
  // $(".display").load($(this).closest('form').attr('action') + ' form')

  function blockUnblockProcessingDiv(flag, text) {
    if (flag) {
      $('#process_tabs').block({ message: text})
    } else {
      $('#process_tabs').unblock()
    }
  }

  $('#ship_specimens_btn').live('click',
  function() {
    blockUnblockProcessingDiv(true, "Please complete the shipping operation or click Exit when you are done")
    var form = $(this).closest('form');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     // dataType: 'script',

     success: function(response) {
       $(".display").html(response);
     }
    });
    return false;
  }); 

  $('#ship_samples_btn').live('click',
  function() {
    blockUnblockProcessingDiv(true, "Please complete the shipping operation or click Exit when you are done")
    var form = $(this).closest('form');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     // dataType: 'script',

     success: function(response) {
       $(".display").html(response);
     }
    });
    return false;
  });
  

  $('.confirm_link').live('click',
  function() {
    blockUnblockProcessingDiv(true, "Please complete the confirmation operation or click Exit when you are done")
    $(".display").load($(this).attr('href'), function(){
      $(".sample_receipt_tabs").tabs().addClass('ui-tabs-vertical ui-helper-clearfix');
      $(".sample_receipt_tabs li").removeClass('ui-corner-top').addClass('ui-corner-left');
    })

    return false;
  }); 

  $('.finish_confirm').live('click',
  function() {
    blockUnblockProcessingDiv(false, "")
    location.reload();
  })
  
  $('#sample_generate_manifest').live('click',
  function() {
    var form = $(this).closest('form');
    var div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     dataType: 'script',
    
     success: function(response) {
       // TODO - was there before. might want to keep it?
       $(".display").html(response);
  
       // var url = /specimen_shippings/ + response.specimen_shipping.id + ' form'
       // $(div).load(url);       
       
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
  });  
  
  
  $('#generate_manifest').live('click',
  function() {
    var form = $(this).closest('form');
    var div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     success: function(response) {
       var in_edit_mode = $('#in_edit_mode').val()
       // TODO - was there before. might want to keep it?
       // $(".display").html(response);
       var url; 
       if (response.specimen_shipping) {
         url = /specimen_shippings/ + response.specimen_shipping.id + '?in_edit_mode=' + in_edit_mode + ' form'
       }
       if (response.sample_shipping) {
         url = /sample_shippings/ + response.sample_shipping.id + '?in_edit_mode=' + in_edit_mode + ' form'
       }
       $(div).load(url);       
       
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
  });  
  
  $('#email_manifest').live('click',
  function() {
    var form = $(this).closest('form');
    var div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
    
     success: function(response) {
       $(div).html(response);
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
  });  
  

  $('.specimen_sample_receive').live('click',
  function() {
      cleanCheckboxes();
      blockUnblockProcessingDiv(true, "Please complete the receive operation or click Exit when you are done")
      sample_processes_dialog($(this).attr('href') + ' form');
      return false;
  });
  
  $('.specimen_sample_store').live('click',
  function() {
      cleanCheckboxes();
      blockUnblockProcessingDiv(true, "Please complete the store operation or click Exit when you are done")
      sample_processes_dialog($(this).attr('href') + ' form');
      return false;
  });
  
  $('.edit_specimen_sample_receive').live('click',
  function() {
      cleanCheckboxes();
      sample_processes_dialog($(this).attr('href') + ' form');
      return false;
  });
  
  $('.edit_specimen_sample_store').live('click',
  function() {
      cleanCheckboxes();
      sample_processes_dialog($(this).attr('href') + ' form');
      return false;
  });  
  
  $('.sample_received').live('click', sample_received_process);
  
  $('.update_sample_received').live('click', sample_update_process);

  $('.spec_stored').live('click', {edit:false}, new_update_specimen_storage);

  $('.update_spec_stored').live('click', {edit:true}, new_update_specimen_storage)

  function cleanCheckboxes() {
    $(':checkbox:checked').each( function() {
      this.checked = !this.checked;
      $('#ship_samples_btn').attr("disabled", false)
      $('#ship_specimens_btn').attr("disabled", false)
    });
    $('#ship_samples :checkbox').attr("disabled", false)
    $('#ship_specimens :checkbox').attr("disabled", false)
  }

  function new_update_specimen_storage(event) {
    var edit = event.data.edit
    var form = $(this).closest('form'),
        div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
      type: $(form).attr('method'),
      url: $(form).attr('action'),
      data: $(form).serializeArray(),
      dataType: 'json',

      success: function(response) {
        var in_edit_mode = $('#in_edit_mode').val()
        $(submitInput).removeAttr('disabled');
        $(submitInput).val('Submit')
        
        var url = /specimen_storages/ + response.specimen_storage.id + '?in_edit_mode=' + in_edit_mode + ' form';
        $(div).load(url);
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

  function sample_update_process(){
    var form = $(this).closest('form'),
        div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
      type: $(form).attr('method'),
      url: $(form).attr('action'),
      data: $(form).serializeArray(),
      dataType: 'json',
      success: function(response) {
        var in_edit_mode = $('#in_edit_mode').val()

        if (response.sample_receipt_store) {
          var url = /sample_receipt_stores/ + response.sample_receipt_store.id + '?in_edit_mode=' + in_edit_mode + ' form';
          $(div).load(url);
        }
        // TODO = after verifying all == delete         if (response.specimen_receipt) {
        if (response.specimen_receipt) {
          var url = /specimen_receipts/ + response.specimen_receipt.id + '?in_edit_mode=' + in_edit_mode + ' form';
          $(div).load(url);
        }
        if (response.specimen_storage_container) {
          var url = /specimen_receipts/ + response.specimen_storage_container.id + ' form';
          $(div).load(url);
        }
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
  
  function sample_received_process() {
    var form = $(this).closest('form'),
        div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
      type: $(form).attr('method'),
      url: $(form).attr('action'),
      data: $(form).serializeArray(),
      dataType: 'json',
      success: function(response) {
        // TODO = after verifying all == delete         if (response.specimen_storage_container) {
        if (response.specimen_receipt) {
          var url = /specimen_receipts/ + response.specimen_receipt.id + ' form';
          $(div).load(url);
        } 
        if (response.specimen_storage_container) {
          var url = /specimen_receipts/ + response.specimen_storage_container.id + ' form';
          $(div).load(url);
        } 
        
        if (response.sample_receipt_store) {
          var url = /sample_receipt_stores/ + response.sample_receipt_store.id + ' form';
          $(div).load(url);
        }
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
  
  var sample_processes_dialog = function(url) {
    $(".display").load(url, function(response, status, xhr) {
      if (status == "error") {
        blockUnblockProcessingDiv(false, "")
        var msg = "Sorry but there was an error: ";
        $("#error").html(msg + xhr.status + " " + xhr.statusText);
        $(".display").prepend('<div id="errorExplanation" class="errorExplanation"/>')
        $('#errorExplanation').html(msg + xhr.status + " " + xhr.statusText);
      }
    });
  }  
});