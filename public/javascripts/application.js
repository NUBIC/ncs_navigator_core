// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

NCSCore = {};
NCSCore.UI = {};

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
  var s = $(select_id+" option:selected");
  var o = $(other_id);

  // making sure the object id's given above exist on page
  if ( (o.size() > 0) && (s.size() > 0) ) {
    // 'Other' = -5
    if (s.val() == "-5") {
      o.removeAttr('disabled');
      // to make the change more visible
      o.css('background-color', '#FAFAD2'); 
      o.css('border', '2px solid #808080'); 
    } else {
      // clear the other field
      o.val(''); 
      o.attr('disabled', 'disabled');
      // to make disabled more visible
      o.css('border', '1px solid #ccc'); 
      o.css('background-color', '#ccc'); 
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