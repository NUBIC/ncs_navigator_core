# -*- coding: utf-8 -*-
class PbsCodeListLoader

  def self.load_codes
    [
      ['INOUT_FRAME_CL1', 'Provider in final sampling frame', '1'],
      ['INOUT_FRAME_CL1', 'Provider not in final sampling frame', '2'],
      ['INOUT_FRAME_CL1', 'Missing in Error', '-4'],

      ['ORIGINAL_SUBSTITUTE_SAMPLE_CL1', 'Original sample provider location', '1'],
      ['ORIGINAL_SUBSTITUTE_SAMPLE_CL1', 'Substitute sample provider location', '2'],
      ['ORIGINAL_SUBSTITUTE_SAMPLE_CL1', 'Missing in Error', '-4'],
      ['ORIGINAL_SUBSTITUTE_SAMPLE_CL1', 'Not applicable', '-7'],

      ['INOUT_PSU_CL1', 'Inside sampled PSU', '1'],
      ['INOUT_PSU_CL1', 'Outside sampled PSU', '2'],
      ['INOUT_PSU_CL1', 'Missing in Error', '-4'],

      ['CERT_UNIT_CL1', 'Certainty Unit', '1'],
      ['CERT_UNIT_CL1', 'Non-Certainty Unit', '2'],
      ['CERT_UNIT_CL1', 'Unknown', '-6'],
      ['CERT_UNIT_CL1', 'Missing in Error', '-4'],

      ['RECRUIT_STATUS_CL1', 'Provider Recruited', '1'],
      ['RECRUIT_STATUS_CL1', 'Provider Not Recruited', '2'],
      ['RECRUIT_STATUS_CL1', 'Provider Recruitment In Progress', '3'],
      ['RECRUIT_STATUS_CL1', 'Recruitment Not Started', '4'],
      ['RECRUIT_STATUS_CL1', 'Out of Scope', '5'],
      ['RECRUIT_STATUS_CL1', 'Not applicable', '-7'],
      ['RECRUIT_STATUS_CL1', 'Missing in Error', '-4'],

      ['PROVIDER_LOGISTICS_CL1', 'Provider location required documentation that IRB review not necessary', '1'],
      ['PROVIDER_LOGISTICS_CL1', 'Provider location required IRB review of entire protocol', '2'],
      ['PROVIDER_LOGISTICS_CL1', 'Provider location had to clear project with larger organization', '3'],
      ['PROVIDER_LOGISTICS_CL1', 'Provider location required formal MOU', '4'],
      ['PROVIDER_LOGISTICS_CL1', 'Provider location required letter of agreement', '5'],
      ['PROVIDER_LOGISTICS_CL1', 'Provider location required subcontract/personal service agreement', '6'],
      ['PROVIDER_LOGISTICS_CL1', 'None', '7'],
      ['PROVIDER_LOGISTICS_CL1', 'Provider location required other logistical arrangements', '-5'],
      ['PROVIDER_LOGISTICS_CL1', 'Missing in Error', '-4'],

      ['NON_INTERVIEW_CL1', 'Closed', '1'],
      ['NON_INTERVIEW_CL1', 'Refusal', '2'],
      ['NON_INTERVIEW_CL1', 'No Prenatal Care', '3'],
      ['NON_INTERVIEW_CL1', 'Location Moved', '4'],
      ['NON_INTERVIEW_CL1', 'Other', '-5'],
      ['NON_INTERVIEW_CL1', 'Not applicable', '-7'],
      ['NON_INTERVIEW_CL1', 'Missing in Error', '-4'],

      ['INFORMATION_SOURCE_CL8', 'Neighboring Business/Person', '1'],
      ['INFORMATION_SOURCE_CL8', 'Postal Carrier/Post Office', '2'],
      ['INFORMATION_SOURCE_CL8', 'Building Manager', '3'],
      ['INFORMATION_SOURCE_CL8', 'Security Office', '4'],
      ['INFORMATION_SOURCE_CL8', 'Rental Office', '5'],
      ['INFORMATION_SOURCE_CL8', 'Other Practice Location', '6'],
      ['INFORMATION_SOURCE_CL8', 'No one', '7'],
      ['INFORMATION_SOURCE_CL8', 'Other', '-5'],
      ['INFORMATION_SOURCE_CL8', 'Not applicable', '-7'],
      ['INFORMATION_SOURCE_CL8', 'Missing in Error', '-4'],

      ['REFUSAL_PROVIDER_CL1', 'Receptionist', '1'],
      ['REFUSAL_PROVIDER_CL1', 'Office Manager', '2'],
      ['REFUSAL_PROVIDER_CL1', 'Physician\'s Assistant', '3'],
      ['REFUSAL_PROVIDER_CL1', 'Nurse/LPN', '4'],
      ['REFUSAL_PROVIDER_CL1', 'Physician', '5'],
      ['REFUSAL_PROVIDER_CL1', 'Other', '-5'],
      ['REFUSAL_PROVIDER_CL1', 'Not applicable', '-7'],
      ['REFUSAL_PROVIDER_CL1', 'Missing in Error', '-4'],

      ['REFUSAL_INTENSITY_CL2', 'Soft/Mild, Non-Hostile', '1'],
      ['REFUSAL_INTENSITY_CL2', 'Hard/Firm, Non-Hostile', '2'],
      ['REFUSAL_INTENSITY_CL2', 'Hostile', '3'],
      ['REFUSAL_INTENSITY_CL2', 'Unknown', '-6'],
      ['REFUSAL_INTENSITY_CL2', 'Not applicable', '-7'],
      ['REFUSAL_INTENSITY_CL2', 'Missing in Error', '-4'],

      ['REFUSAL_REASON_CL2', 'Too busy', '1'],
      ['REFUSAL_REASON_CL2', 'The provider does not participate in research', '2'],
      ['REFUSAL_REASON_CL2', 'Provider thinks patients will not participate in research', '3'],
      ['REFUSAL_REASON_CL2', 'Does not see benefits to patients', '4'],
      ['REFUSAL_REASON_CL2', 'Parent organization will not allow', '5'],
      ['REFUSAL_REASON_CL2', 'HIPAA restrictions', '6'],
      ['REFUSAL_REASON_CL2', 'IRB restrictions', '7'],
      ['REFUSAL_REASON_CL2', 'Needs compensation for provider effort', '8'],
      ['REFUSAL_REASON_CL2', 'Insufficient resources to participate', '9'],
      ['REFUSAL_REASON_CL2', 'Other', '-5'],
      ['REFUSAL_REASON_CL2', 'Unknown', '-6'],
      ['REFUSAL_REASON_CL2', 'Not applicable', '-7'],
      ['REFUSAL_REASON_CL2', 'Missing in Error', '-4'],

    ].each do |list_name, text, code|
      NcsCode.find_or_create_by_list_name_and_display_text_and_local_code(list_name, text, code)
    end
  end

end