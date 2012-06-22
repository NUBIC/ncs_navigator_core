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
    ].each do |list_name, text, code|
      NcsCode.find_or_create_by_list_name_and_display_text_and_local_code(list_name, text, code)
    end
  end
  
end