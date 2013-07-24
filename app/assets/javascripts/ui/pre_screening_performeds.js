NCSCore.UI.PreScreeningPerformedAssociation = function (config) {
  var preScreeningPerformedAttributesForm = new NestedAttributes({
      container: $('.pre_screening_performeds'),
      association: 'pre_screening_performeds',
      content: config.preScreeningPerformedsTemplate,
      addHandler: null,
      caller: this
   });
};