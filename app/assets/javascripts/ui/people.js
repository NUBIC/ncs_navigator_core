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