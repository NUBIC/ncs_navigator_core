NCSCore.UI.PPGStatus = function (config) {
  var ppgStatusNestedAttributesForm = new NestedAttributes({
      container: $('.ppg_status_histories'),
      association: 'ppg_status_histories',
      content: config.ppgStatusTemplate,
      addHandler: null,
      caller: this
   });
};