NCSCore.UI.PbsList = function (config) {

  var success_path = config.successPath;

  var onsuccess = function(data) {
    var staff_id = data.id
    var provider_id = data.provider_id

    var url = "/people/" + staff_id + "/" + success_path + "?provider_id=" + provider_id;
    var img = '<img src="/assets/ajax-loader.gif" alt="Loading" height="16" width="16"></img>'

    // if updating existing record
    if($('div#staff_' + staff_id).exists()) {
      $('div#staff_' + staff_id).html('<p>Updating ...' + img + '</p>');
      $.get(url, null, function (response) {
        $('div#staff_' + staff_id).replaceWith(response);
      });
    // otherwise creating new record
    } else {
      $('div#new_staff').html('<p>Creating new record ...' + img + '</p>');
      $.get(url, null, function (response) {
        $('.instructional_note').hide();
        $('#staff_line_items').append(response);
        $('div#new_staff').html('');
      });
    }
    $('#dialog').remove();
  }


  $('.edit_staff_modal_form_link').live('click', function() {
    $('<div id="dialog"/>').appendTo('body').load($(this).attr('href') + ' form').dialog({
      title: $(this).attr('title'),
      // autoOpen: false,
      height: 650,
      width: 800,
      modal: true,
      buttons: {
        Save: function() {
          var url = $("#modal_edit_form").attr('action');
          var dlg = $(this);
          var valid = $("#modal_edit_form").validate().form();
          if (valid == true) {
            $.ajax({
              type: 'POST',
              url: url,
              data: $("#modal_edit_form").serializeArray(),
              dataType: 'json',
              success: function(response) {
                onsuccess(response);
                dlg.dialog('close');
              }
            });
          }
        },
        Cancel: function() {
          $(this).dialog('close')
        }
      },
      open: function() {

      },
      close: function() {

      }
    });
    return false;
  });

};