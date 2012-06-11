$(function() {

  $('.my_specimen_sample_receive').live('click',
  function() {
      sample_processes_dialog($(this).attr('href') + ' form', 'Biological Specimens / Environmental Samples Receiving Form', $(this).attr('rel'));
      return false;
  });
  
  $('.my_specimen_sample_store').live('click',
  function() {
      console.log("---- HREF --- ", $(this).attr('href'))
      console.log("---- REL --- ", $(this).attr('rel'))      
      sample_processes_dialog($(this).attr('href') + ' form', 'Biological Specimens / Environmental Samples Receiving Form', $(this).attr('rel'));
      return false;
  });
  
  $('.sample_received').live('click', sample_received_process);

  $('.spec_stored').live('click', my_specimen_storage_dialog);

  function my_specimen_storage_dialog() {
    var form = $(this).closest('form'),
        div = $(form).closest('div');
    var submitInput = $(this)
    $.ajax({
      type: $(form).attr('method'),
      url: $(form).attr('action'),
      data: $(form).serializeArray(),
      dataType: 'json',

      success: function(response) {
        $(submitInput).removeAttr('disabled');
        $(submitInput).val('Submit')
        
        var storage_container_id = response.specimen_storage.storage_container_id;
        var url = /specimen_storages/ + response.specimen_storage.id + ' form';
        $(div).load(url);
        remove_link_from_receive_store(response.specimen_storage.storage_container_id)
        add_link_to_ship(response.specimen_storage.storage_container_id)
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
        if (response.specimen_receipt) {
          var specimen_id = response.specimen_receipt.specimen_id;
          var url = /specimen_receipts/ + response.specimen_receipt.id + ' form';
          $(div).load(url);
          remove_link_from_receive_store(response.specimen_receipt.specimen_id)
          add_specimen_link_to_store(response.specimen_receipt.storage_container_id, response.specimen_receipt.specimen_id)
        } 
        if (response.sample_receipt_store) {
          var sample_id = response.sample_receipt_store.sample_id;
          var url = /sample_receipt_stores/ + response.sample_receipt_store.id + '?receive=true form';
          $(div).load(url);
          remove_link_from_receive_store(response.sample_receipt_store.sample_id)
          add_link_to_ship(response.sample_receipt_store.sample_id)
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
  
  function remove_link_from_receive_store(id) {
    var link = $("#" + id)
    var linkParent = link.parent()
    link.remove()
    linkParent.remove()
  }
  
  function add_specimen_link_to_store(storage_container_id, specimen_id) {
    var div = $("#storing")
    
  }
  
  function add_link_to_ship(id) {
    
  }
  
  
  var sample_processes_dialog = function(url, title, success_url) {
    $(".display").load(url)
  }  
});