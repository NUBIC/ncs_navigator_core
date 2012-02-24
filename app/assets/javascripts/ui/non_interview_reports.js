NCSCore.UI.NonInterviewReportAssociation = function (config) {
  var noAccessNonInterviewReportAttributesForm = new NestedAttributes({
      container: $('.no_access_non_interview_reports'),
      association: 'no_access_non_interview_reports',
      content: config.noAccessNonInterviewReportTemplate,
      addHandler: null,
      caller: this
   });
   
  var refusalNonInterviewReportAttributesForm = new NestedAttributes({
      container: $('.refusal_non_interview_reports'),
      association: 'refusal_non_interview_reports',
      content: config.refusalNonInterviewReportTemplate,
      addHandler: null,
      caller: this
   });
   
  var dwellingUnitTypeNonInterviewReportAttributesForm = new NestedAttributes({
      container: $('.dwelling_unit_type_non_interview_reports'),
      association: 'dwelling_unit_type_non_interview_reports',
      content: config.dwellingUnitTypeNonInterviewReportTemplate,
      addHandler: null,
      caller: this
   });
   
 var vacantInterviewReportAttributesForm = new NestedAttributes({
     container: $('.vacant_non_interview_reports'),
     association: 'vacant_non_interview_reports',
     content: config.vacantNonInterviewReportTemplate,
     addHandler: null,
     caller: this
  });
};