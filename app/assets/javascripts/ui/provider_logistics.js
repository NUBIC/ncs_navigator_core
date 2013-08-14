NCSCore.UI.ProviderLogisticAssociation = function (config) {
  var providerLogisticsAttributesForm = new NestedAttributes({
      container: $('.provider_logistics'),
      association: 'provider_logistics',
      content: config.providerLogisticTemplate,
      addHandler: null,
      caller: this
   });
};

function setCompletionDateForNoneLogistic() {
	$('.provider_logistics td.select_col').each(function() {
		logistic_selector = $(this).children("select:first")
		completion_date = $(this).children(".completion_date").find("input")
		if (completion_date.length > 0 && completion_date.val().length == 0) {
			logistic_selector.change(function() {
				if (logistic_selector.find("option:selected").val() == 7) {
					completion_date.val(get_today_date_in_mdes_format())
				} else {
					completion_date.val('')
				}
			})
		}
	})
}
