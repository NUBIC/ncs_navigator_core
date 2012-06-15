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
    } else {
      $('#ship_samples :checkbox').attr("disabled", false);
      $('#ship_samples_btn').attr("disabled", false)
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
    } else {
      $('#ship_specimens :checkbox').attr("disabled", false);
      $('#ship_specimens_btn').attr("disabled", false)      
    }
  })

  $('.exit_shipping').live('click',
  function() {
    blockUnblockProcessingDiv(false)
    $(':checkbox:checked').each( function() {
      this.checked = !this.checked;
    });
    $(':submit').each( function() {
      $(this).attr("disabled", false)
    })
    $('#displaying').children().each(function(){$(this).remove()})
  })
  
  $('.finish_shipping').live('click',
  function() {
    blockUnblockProcessingDiv(false)
    $(':submit').each( function() {
      $(this).attr("disabled", false)
    })
    //TODO 
    //Make sure the checkboxes disappear from the ship and link is added to confirm
    $(':checkbox:checked').each( function() {
      $(this).parent().remove()
    });
    $('#displaying').children().each(function(){$(this).remove()})
    //todo double check the last line!
    $('#shipping :checkbox').attr("disabled", false)
  })

  //kak submittit' bez dannih
  // $(".display").load($(this).closest('form').attr('action') + ' form')

  function blockUnblockProcessingDiv(flag) {
    if (flag) {
      $('#process_tabs').block({ message: "Please complete the shipping operation or click Done"})
    } else {
      $('#process_tabs').unblock()
    }
  }

  $('#ship_specimens_btn').live('click',
  function() {
    blockUnblockProcessingDiv(true)
    var form = $(this).closest('form');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     dataType: 'script',

     success: function(response) {
       $(".display").html(response);
     }
    });
    return false;
  }); 

  $('#ship_samples_btn').live('click',
  function() {
    blockUnblockProcessingDiv(true)
    var form = $(this).closest('form');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     dataType: 'script',

     success: function(response) {
       $(".display").html(response);
     }
    });
    return false;
  });
  
  $('#generate_manifest').live('click',
  function() {
    var form = $(this).closest('form');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     dataType: 'script',
    
     success: function(response) {
       $(".display").html(response);
     }
    });
    return false;
  });  
  
  $('#email_manifest').live('click',
  function() {
    var form = $(this).closest('form');
    var submitInput = $(this)
    $.ajax({
     type: $(form).attr('method'),
     url: $(form).attr('action'),
     data: $(form).serializeArray(),
     dataType: 'script',
    
     success: function(response) {
       $(".display").html(response);
     }
    });
    return false;
  });  
  

  $('.my_specimen_sample_receive').live('click',
  function() {
      sample_processes_dialog($(this).attr('href') + ' form', 'Biological Specimens / Environmental Samples Receiving Form', $(this).attr('rel'));
      return false;
  });
  
  $('.my_specimen_sample_store').live('click',
  function() {
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
        move_link_from_store_to_ship(response.specimen_storage.storage_container_id)
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
          add_sample_link_to_ship(response.sample_receipt_store.sample_id)
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
  
  function remove_link_from_receive_store(storage_container_id) {
    var link = $("#" + storage_container_id)
    var linkParent = link.parent()
    link.remove()
    linkParent.remove()
  }
  
  function move_link_from_store_to_ship(storage_container_id) {
    var link = $("#" + storage_container_id)
    var link_children = link.html()
    var linkParent = link.parent()
    checkbox = "<input id="+storage_container_id + " class=specimen_ship_checkbox name=storage_container_id[] type=checkbox value=" + storage_container_id + ">"
    link.remove()
    linkParent.append(checkbox)
    linkParent.append(link_children)
    $("#ship_specimens").first().append(linkParent);
  }
  
  function add_specimen_link_to_store(storage_container_id, specimen_id) {
    var a_with_id = $("#storing a[id=" + storage_container_id + "]")
    if (a_with_id.length != 0) {
      text_elt = "<p class=\"paragraph_shift\">"+specimen_id+"</p>"
      a_with_id.append(text_elt)
    } else {
      link_elt = "<li><a id="+storage_container_id+ " class=\"my_specimen_sample_store\" href=\"/specimen_storages/new?container_id="+storage_container_id+"\"> Pressure bag: " + storage_container_id+ "<p class=\"paragraph_shift\">"+specimen_id+"</p></a></li>"
      $("#storing ul").first().append(link_elt);
    }
  }
  
  // function add_specimen_link_to_ship(storage_container_id, specimen_id){
  //   link_elt = "<li><input id="+storage_container_id + " class=specimen_ship_checkbox name=storage_container_id[] type=checkbox value=" + storage_container_id + "><a id="+storage_container_id+ " class=\"my_specimen_ship\" href=\"/specimen_storages/new?container_id="+storage_container_id+"\"> Pressure bag: " + storage_container_id+ "<p class=\"paragraph_shift\">"+specimen_id+"</p></a></li>"
  //   $("#ship_specimens").first().append(link_elt);
  // }
  
  function add_sample_link_to_ship(sample_id) {
    // link_elt = "<li><input id="+sample_id + " class=sample_ship_checkbox name=sample_id[] type=checkbox value=" + sample_id + "><a id="+sample_id+ " class=\"my_sample_ship\" href=\"/sample_receipt_stores/new?sample_id="+sample_id+"\"> " + sample_id+ "</a></li>"
    link_elt = "<li><input id="+sample_id + " class=sample_ship_checkbox name=sample_id[] type=checkbox value=" + sample_id + ">"+ sample_id +"</li>"
    $("#ship_samples").first().append(link_elt);
  }
  
  
  var sample_processes_dialog = function(url, title, success_url) {
    $(".display").load(url)
  }  
});