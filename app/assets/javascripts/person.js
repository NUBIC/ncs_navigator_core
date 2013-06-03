$(function (){
  $("#enable_person_dob_derivatives").click(function() {
    $(".person_dob_derivatives").prop('disabled',false);
    $('#disable_person_dob_derivatives').show();
    $('#enable_person_dob_derivatives').hide();
  });

  $("#disable_person_dob_derivatives").click(function() {
    $(".person_dob_derivatives").prop('disabled',true);
    $('#disable_person_dob_derivatives').hide();
    $('#enable_person_dob_derivatives').show();
  });
});
