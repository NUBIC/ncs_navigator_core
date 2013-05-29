# -*- coding: utf-8 -*-

module OperationalDataExtractor

  autoload :Base,                       'operational_data_extractor/base'
  autoload :ParticipantVerification,    'operational_data_extractor/participant_verification'
  autoload :PbsEligibilityScreener,     'operational_data_extractor/pbs_eligibility_screener'
  autoload :PregnancyScreener,          'operational_data_extractor/pregnancy_screener'

  autoload :PpgFollowUp,                'operational_data_extractor/ppg_follow_up'
  autoload :PrePregnancy,               'operational_data_extractor/pre_pregnancy'
  autoload :PregnancyVisit,             'operational_data_extractor/pregnancy_visit'
  autoload :LowIntensityPregnancyVisit, 'operational_data_extractor/low_intensity_pregnancy_visit'
  autoload :TracingModule,              'operational_data_extractor/tracing_module'
  autoload :Birth,                      'operational_data_extractor/birth'
  autoload :PostNatal,                  'operational_data_extractor/post_natal'

  autoload :Sample,                     'operational_data_extractor/sample'
  autoload :Specimen,                   'operational_data_extractor/specimen'

  EXTRACTORS = [
    [/_PBSPartVerBirth_/,  OperationalDataExtractor::PbsParticipantVerification],
    [/_ParticipantVerif_/,  OperationalDataExtractor::ParticipantVerification],
    [/_Tracing_/,           OperationalDataExtractor::TracingModule],
    [/_PBSamplingScreen_/,  OperationalDataExtractor::PbsEligibilityScreener],
    [/_PBSampScreenHosp_/,  OperationalDataExtractor::PbsEligibilityScreener],
    [/_PregScreen_/,        OperationalDataExtractor::PregnancyScreener],
    [/_PPGFollUp_/,         OperationalDataExtractor::PpgFollowUp],
    [/_PrePreg_/,           OperationalDataExtractor::PrePregnancy],
    [/_PregVisit/,          OperationalDataExtractor::PregnancyVisit],
    [/_LIPregNotPreg/,      OperationalDataExtractor::LowIntensityPregnancyVisit],
    [/_Birth/,              OperationalDataExtractor::Birth],
    [/_AdultBlood_/,        OperationalDataExtractor::Specimen],
    [/_AdultUrine_/,        OperationalDataExtractor::Specimen],
    [/_CordBlood_/,         OperationalDataExtractor::Specimen],
    [/_TapWater/,           OperationalDataExtractor::Sample],
    [/_VacBagDust/,         OperationalDataExtractor::Sample],
    [/_3MMother/,           OperationalDataExtractor::PostNatal],
    [/_6MMother/,           OperationalDataExtractor::PostNatal],
    [/_9MMother/,           OperationalDataExtractor::PostNatal],
    [/_12MMother/,          OperationalDataExtractor::PostNatal],
    [/_18MMother/,          OperationalDataExtractor::PostNatal],
    [/_24MMother/,          OperationalDataExtractor::PostNatal],
    [/_ChildBlood_/,        OperationalDataExtractor::Specimen],
    [/_ChildSalivaColl_/,   OperationalDataExtractor::Specimen],
    [/_ChildUrineColl_/,    OperationalDataExtractor::Specimen],
    [/_BreastMilkColl_/,    OperationalDataExtractor::Specimen],
    [/_SampleDistrib_/,     OperationalDataExtractor::Sample],
    [/_Informed_Consent/,   OperationalDataExtractor::InformedConsent],
    [/_Withdrawal/,         OperationalDataExtractor::InformedConsent],
    [/_Reconsent/,          OperationalDataExtractor::InformedConsent],
    [/_NonInterviewReport/, OperationalDataExtractor::NonInterviewReport],
  ]

  class InvalidSurveyException < StandardError; end
end
