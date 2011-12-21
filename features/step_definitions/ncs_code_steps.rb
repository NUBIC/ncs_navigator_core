Given /^valid ncs codes$/ do
  Factory(:ncs_code, :list_name => "PSU_CL1", :display_text => "Cook County, IL (Wave 1)", :local_code => NcsNavigatorCore.psu)
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1)
  Factory(:ncs_code, :list_name => "HOUSEHOLD_ELIGIBILITY_CL2", :display_text => "Household is eligible", :local_code => 1)
  Factory(:ncs_code, :list_name => "RESIDENCE_TYPE_CL2", :display_text => "Single-Family Home", :local_code => 1)
  Factory(:ncs_code, :list_name => "NAME_PREFIX_CL1", :display_text => "Mr.", :local_code => 1)
  Factory(:ncs_code, :list_name => "NAME_SUFFIX_CL1", :display_text => "Jr.", :local_code => 1)
  Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Male", :local_code => 1)
  Factory(:ncs_code, :list_name => "AGE_RANGE_CL1", :display_text => "18-24", :local_code => 2)
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1)
  Factory(:ncs_code, :list_name => "ETHNICITY_CL1", :display_text => "Not Hispanic or Latino", :local_code => 2)
  Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1)
  Factory(:ncs_code, :list_name => "MARITAL_STATUS_CL1", :display_text => "Married", :local_code => 1)
  Factory(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1)
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL1", :display_text => "Yes", :local_code => 1)  
  Factory(:ncs_code, :list_name => "MOVING_PLAN_CL1", :display_text => "Address known", :local_code => 1)  
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL4", :display_text => "Yes", :local_code => 1)  
  Factory(:ncs_code, :list_name => "INFORMATION_SOURCE_CL4", :display_text => "Person/Self", :local_code => 1)

  Factory(:ncs_code, :list_name => "PARTICIPANT_TYPE_CL1", :display_text => "Age-eligible woman", :local_code => 1)
  Factory(:ncs_code, :list_name => "INFORMATION_SOURCE_CL4", :display_text => "Person/Self", :local_code => 1)
  Factory(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1)
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1)
  Factory(:ncs_code, :list_name => "STUDY_ENTRY_METHOD_CL1", :display_text => "Advance letter mailed by NCS.", :local_code => 1)
  Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL2", :display_text => "Age-Eligible", :local_code => 1)
  
  Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Visit  1", :local_code => 13)
  Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Screener", :local_code => 29)
  Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Probability", :local_code => 7)
  Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low Intensity Data Collection", :local_code => 33)
  Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low to High Conversion", :local_code => 32)
  Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pre-Pregnancy Visit", :local_code => 11)

  Factory(:ncs_code, :list_name => "TRANSLATION_METHOD_CL3", :display_text => "Legitimate Skip", :local_code => -3)
  Factory(:ncs_code, :list_name => "CONTACT_LOCATION_CL1", :display_text => "Person/participant home", :local_code => 1)
  Factory(:ncs_code, :list_name => "CONTACTED_PERSON_CL1", :display_text => "NCS Participant", :local_code => 1)
  
  Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
  Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2)
  Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3)
  Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Other Probability – Not Pregnancy and not Trying", :local_code => 4)
  Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 5: Ineligible", :local_code => 5)
  Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 6: Withdrawn", :local_code => 6)
  
  Factory(:ncs_code, :list_name => "CONSENT_TYPE_CL1", :display_text => "Low Intensity Consent", :local_code => 7)
  
  Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  
  create_missing_in_error_ncs_codes(Person)
  create_missing_in_error_ncs_codes(HouseholdUnit)
  create_missing_in_error_ncs_codes(DwellingUnit)
  create_missing_in_error_ncs_codes(Address)
  create_missing_in_error_ncs_codes(HouseholdPersonLink)
  create_missing_in_error_ncs_codes(PpgStatusHistory)
  create_missing_in_error_ncs_codes(Participant)
  create_missing_in_error_ncs_codes(ContactLink)
  create_missing_in_error_ncs_codes(Contact)
  create_missing_in_error_ncs_codes(Event)
  create_missing_in_error_ncs_codes(Instrument)
  create_missing_in_error_ncs_codes(PpgDetail)
  create_missing_in_error_ncs_codes(ParticipantConsent)
end


def create_missing_in_error_ncs_codes(cls)
  cls.reflect_on_all_associations.each do |association|
    if association.options[:class_name] == "NcsCode"
      list_name = association.options[:conditions].gsub("'", "").gsub("list_name = ", "")
      Factory(:ncs_code, :local_code => '-4', :display_text => 'Missing in Error', :list_name => list_name)
    end
  end
end