NCSCore.UI.People = function (config) {
  var setupPeopleAutocompleter = function () {
      $(".people_combobox_autocompleter").combobox({ watermark: 'person' });
   },
  peopleNestedAttributesForm = new NestedAttributes({
      container: $('.household_person_links'),
      association: 'household_person_links',
      content: config.peopleTemplate,
      addHandler: setupPeopleAutocompleter,
      caller: this
   });
   setupPeopleAutocompleter();
};

$(document).ready(function() {

  $('.sampled_persons_ineligibility').hide(); //hide fields on start
   $('.provider_association').change(function() {
       if($('.pre_screening_status_selector').val() == '2' && $('.sampled_person_code_selector').val() == '1') { //if this value is selected
           $('.sampled_persons_ineligibility').show(); //this field is shown
       }
       else {
           $('.sampled_persons_ineligibility').hide();//else it is hidden
       }

    });
});
