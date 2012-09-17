$(document).ready(function() {

  $("#new_contact").validate();

  $(".edit_provider").validate({
    debug: true,
    rules: {
      'provider[address_attributes][unit]': {
        maxlength: 10,
      },
    },
  });

});