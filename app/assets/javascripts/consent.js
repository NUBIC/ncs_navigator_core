$(document).ready(function() {
  $("#participant_consent_consent_given_code").change(function(event) {
    var selected_value = $('#participant_consent_consent_given_code').val();
    if (selected_value == 1) {
      $("#low_intensity_consent_script").hide();
      $("#low_intensity_consent_yes").show();
      $("#low_intensity_consent_no").hide();
    } else if (selected_value == 2) {
      $("#low_intensity_consent_script").hide();
      $("#low_intensity_consent_no").show();
      $("#low_intensity_consent_yes").hide();
    } else {
      $("#low_intensity_consent_script").show();
      $("#low_intensity_consent_no").hide();
      $("#low_intensity_consent_yes").hide();
    }
    window.scroll(0,0);
  })
});