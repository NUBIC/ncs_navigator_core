$(document).ready(function() {

  $(".new_person").validate();
  $(".edit_person").validate();

  $(".edit_contact_link").validate({
    rules: {
      'contact[contact_distance]': {
        maxlength: 4,
        number: true
      }
    }
  });

  $(".edit_contact").validate();
  $(".new_contact").validate();

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

  $(".new_telephone").validate();
  $(".edit_telephone").validate();

  $(".new_address").validate();
  $(".edit_address").validate();

  $(".new_email").validate();
  $(".edit_email").validate();


});