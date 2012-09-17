$(document).ready(function() {

  $("#new_contact").validate();

  $(".edit_provider").validate({
    rules: {
      'provider[name_practice]': {
        maxlength: 100,
      },
      'provider[address_attributes][address_one]': {
        maxlength: 100,
      },
      'provider[address_attributes][address_two]': {
        maxlength: 100,
      },
      'provider[address_attributes][unit]': {
        maxlength: 10,
      },
      'provider[address_attributes][city]': {
        maxlength: 50,
      },
      'provider[address_attributes][zip]': {
        maxlength: 5,
        number: true
      },
      'provider[address_attributes][zip4]': {
        maxlength: 4,
        number: true
      },
    },
  });

});