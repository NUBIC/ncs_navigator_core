$(document).ready(function() {

  // participant


  // person
  $(".new_person").validate({
    rules: {
      'person[person_dob]': {
        minlength: 10,
        maxlength: 10
      },
      'person[date_move]': {
        minlength: 7,
        maxlength: 7
      },
      'person[title]': {
        maxlength: 5
      },
      'person[first_name]': {
        maxlength: 30
      },
      'person[last_name]': {
        maxlength: 30
      },
      'person[maiden_name]': {
        maxlength: 30
      },
      'person[middle_name]': {
        maxlength: 30
      }
    }
  });
  $(".edit_person").validate({
    rules: {
      'person[person_dob]': {
        minlength: 10,
        maxlength: 10
      },
      'person[date_move]': {
        minlength: 7,
        maxlength: 7
      },
      'person[title]': {
        maxlength: 5
      },
      'person[first_name]': {
        maxlength: 30
      },
      'person[last_name]': {
        maxlength: 30
      },
      'person[maiden_name]': {
        maxlength: 30
      },
      'person[middle_name]': {
        maxlength: 30
      }
    }
  });

  // contact_link
  $(".edit_contact_link").validate({
    rules: {
      'contact[contact_distance]': {
        maxlength: 6,
        number: true
      }
    }
  });

  // contact
  $(".edit_contact").validate({
    rules: {
      'contact[contact_distance]': {
        maxlength: 6,
        number: true
      }
    }
  });
  $(".new_contact").validate({
    rules: {
      'contact[contact_distance]': {
        maxlength: 6,
        number: true
      }
    }
  });

  // provider
  $(".edit_provider").validate({
    rules: {
      'provider[name_practice]': {
        maxlength: 100,
      },
      'provider[proportion_weeks_sampled]': {
        number: true,
      },
      'provider[proportion_days_sampled]': {
        number: true,
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

  // pbs_list
  $(".edit_pbs_list").validate({
    rules: {
      "pbs_list[practice_num]": {
        maxlength: 3,
      },
      "pbs_list[mos]": {
        number: true,
      },
      "pbs_list[stratum]": {
        maxlength: 36,
      },
      "pbs_list[sort_var1]": {
        number: true,
      },
      "pbs_list[sort_var2]": {
        number: true,
      },
      "pbs_list[sort_var3]": {
        number: true,
      },
      "pbs_list[frame_order]": {
        number: true,
      },
      "pbs_list[selection_probability_location]": {
        number: true,
        range: [0, 1]
      },
      "pbs_list[sampling_interval_woman]": {
        number: true,
        min: 1
      },
      "pbs_list[selection_probability_woman]": {
        number: true,
        range: [0, 1]
      },
      "pbs_list[selection_probability_overall]": {
        number: true,
        range: [0, 1]
      },
      "pbs_list[pr_recruitment_start_date]": {
        date: true,
      },
      "pbs_list[pr_recruitment_end_date]": {
        date: true,
      },
      "pbs_list[pr_cooperation_date]": {
        date: true,
      },
    },
  });

  // telephone
  $(".new_telephone").validate();
  $(".edit_telephone").validate();

  // address
  $(".new_address").validate({
    rules: {
      'address[zip]': {
        minlength: 5,
        maxlength: 5,
        number: true
      },
      'address[zip4]': {
        minlength: 4,
        maxlength: 4,
        number: true
      }
    }
  });
  $(".edit_address").validate({
    rules: {
      'address[zip]': {
        minlength: 5,
        maxlength: 5,
        number: true
      },
      'address[zip4]': {
        minlength: 4,
        maxlength: 4,
        number: true
      }
    }
  });

  // email
  $(".new_email").validate();
  $(".edit_email").validate();

  // provider
  $(".edit_provider").validate({
    rules: {
      'provider[name_practice]': {
        maxlength: 100
      }
    }
  });
  $(".new_provider").validate({
    rules: {
      'provider[name_practice]': {
        maxlength: 100
      }
    }
  });

});