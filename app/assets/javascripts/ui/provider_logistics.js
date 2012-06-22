NCSCore.UI.ProviderLogisticAssociation = function (config) {
  var providerLogisticsAttributesForm = new NestedAttributes({
      container: $('.provider_logistics'),
      association: 'provider_logistics',
      content: config.providerLogisticTemplate,
      addHandler: null,
      caller: this
   });
};