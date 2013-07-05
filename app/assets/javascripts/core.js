NCSCore = {};
NCSCore.UI = {};

function get_today_date_in_mdes_format() {
  var today= new Date();
  var month = today.getMonth() + 1;
  var day = today.getDate();

  var todayInMdes = today.getFullYear() + '-' +
      ((''+month).length<2 ? '0' : '') + month + '-' +
      ((''+day).length<2 ? '0' : '') + day;
  return todayInMdes;
}

// Used inside document ready method call to wire up selects with other fields
function wire_up_select_other(select_id, other_id) {
  check_select_for_other(select_id, other_id);
  // Check on item change
  $(select_id).change(function() {
    check_select_for_other(select_id, other_id);
  });
}

// Used to enable/disable 'other' input type text field
function check_select_for_other(select_id, other_id) {
  var s = $(select_id + " option:selected");
  var sel = $(select_id);
  var o = $(other_id);

  // making sure the object id's given above exist on page
  if ( (o.size() > 0) && (s.size() > 0) ) {
    // 'Other' = -5
    if (s.val() == "-5") {
      o.removeAttr('disabled');
      // to make the change more visible
      o.css('background-color', '#FAFAD2');
      o.css('border', '2px solid #808080');
      sel.parent('p.ncs_select').next('p.other_field').show();
    } else {
      // clear the other field
      o.val('');
      o.attr('disabled', 'disabled');
      // to make disabled more visible
      o.css('border', '1px solid #ccc');
      o.css('background-color', '#ccc');
      sel.parent('p.ncs_select').next('p.other_field').hide();
    }
  }
}

function stop_default_action(e) {
  if (e &&e.preventDefault) {
    // to disable the default event we call the preventDefault() method of the event handler
    // (for those browsers that recognise standard event listeners)
    e.preventDefault();
  } else if (window.event && window.event.returnValue) {
    // we set the eventReturnValue property to false for Internet Explorer
    // (which uses its own proprietary means of attaching events)
    window.eventReturnValue = false;
  }
}

jQuery.fn.exists = function(){return jQuery(this).length>0;}

$(document).ready(function() {

  $("input[type='text'].datetime").datetimepicker({
    controlType: 'select',
    timeFormat: 'HH:mm:ss',
    dateFormat: 'yy-mm-dd'
  });
  $("input[type='text'].date").datepicker({
    dateFormat: 'yy-mm-dd',
    changeMonth: true,
    changeYear: true,
    yearRange: '1920:2020'
  });
  $("input[type='text'].mdes_date").datepicker({
    dateFormat: 'yy-mm-dd',
    changeMonth: true,
    changeYear: true,
    yearRange: '1920:2020',
    constrainInput: false
  });
  $("input[type='text'].datepicker").datepicker({
    dateFormat: 'yy-mm-dd',
    changeMonth: true,
    changeYear: true,
    yearRange: '1920:2020'
  });
  $("input[type='text'].time").timepicker({
    controlType: 'select'
  });
  $("input[type='text'].timepicker").timepicker({
    controlType: 'select'
  });

  $(".required").after("<span class='required_marker'>*</span>");

  // phone format
  $("input[type='text'].phone").mask("(999) 999-9999");

  // two-digit limiter with '_' as the placeholder
  $("input[type='text'].two_digit_underscore").mask("99", { placeholder: "_" });

  // four-digit limiter with '_' as the placeholder
  $("input[type='text'].four_digit_underscore").mask("9999", { placeholder: "_" });

  // five-digit limiter with '_' as the placeholder
  $("input[type='text'].five_digit_underscore").mask("99999", { placeholder: "_" });

  // two-digit limiter with 'D' as the placeholder
  $("input[type='text'].two_digit_day").mask("99", { placeholder: "D" });

  // four-digit limiter with 'Y' as the placeholder
  $("input[type='text'].four_digit_year").mask("9999", { placeholder: "Y" });

  // four-digit year and two-digit month separated by a hyphen
  $("input[type='text'].four_digit_year_hyphen_two_digit_month").mask("9999-99", { placeholder: 'YYYY-MM' });

  $('.mdes_documentation_link').click(function(event) {
    var definition = $(this).next('.mdes_definition').val();
    var title = $(this).next('.mdes_definition').attr('title');
    $('<div id="dialog" class="modal_dialog">' + definition + '</div>').appendTo('body');
    event.preventDefault();
    $("#dialog").dialog({
      title: title,
      width: 600,
      modal: true,
      close: function(event, ui) {
        $(".modal_dialog").remove();
      }
    });
  });

  $('.help_text_link').click(function(event) {
    var help_text = $(this).next('.help_text').val();
    var title = $(this).next('.help_text').attr('title');
    if ($("#dialog").length == 0) {
      $('<div id="dialog" class="modal_dialog">' + help_text + '</div>').appendTo('body');
    }
    event.preventDefault();
    $("#dialog").dialog({
      title: title,
      width: 600,
      modal: true,
      close: function(event, ui) {
        $(".modal_dialog").remove();
      }
    });
  });

  $(".help_icon").tooltip();
  $(".disposition_icon").tooltip({ position: "bottom left"});
  $(".notification_icon").tooltip();
  $("#tabs").tabs({ cookie: { expires: 1 } });

});
