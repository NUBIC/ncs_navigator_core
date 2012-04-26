# -*- coding: utf-8 -*-


Factory.define :ppg_detail do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_pid_status     { |a| a.association(:ncs_code, :list_name => "PARTICIPANT_STATUS_CL1", :display_text => "Enrolled in low intensity protocol", :local_code => 3) }
  ppg.ppg_first          { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
  ppg.orig_due_date      nil
end

Factory.define :ppg1_detail, :class => PpgDetail do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_pid_status     { |a| a.association(:ncs_code, :list_name => "PARTICIPANT_STATUS_CL1", :display_text => "Enrolled in low intensity protocol", :local_code => 3) }
  ppg.ppg_first          { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
  ppg.orig_due_date      6.months.from_now.strftime("%Y-%m-%d")
  ppg.created_at         Time.now
end

Factory.define :ppg2_detail, :class => PpgDetail do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_pid_status     { |a| a.association(:ncs_code, :list_name => "PARTICIPANT_STATUS_CL1", :display_text => "Enrolled in low intensity protocol", :local_code => 3) }
  ppg.ppg_first          { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
  ppg.orig_due_date      nil
end

Factory.define :ppg_status_history do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_status         { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
  ppg.ppg_info_source    { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Person/Self", :local_code => 1) }
  ppg.ppg_info_mode      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
  ppg.ppg_status_date    '2011-01-01'
end

Factory.define :ppg1_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_status         { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
  ppg.ppg_info_source    { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Person/Self", :local_code => 1) }
  ppg.ppg_info_mode      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
end

Factory.define :ppg2_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_status         { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability - Trying to Conceive", :local_code => 2) }
  ppg.ppg_info_source    { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Person/Self", :local_code => 1) }
  ppg.ppg_info_mode      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
end

Factory.define :ppg3_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_status         { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability - Recent Pregnancy Loss", :local_code => 3) }
  ppg.ppg_info_source    { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Person/Self", :local_code => 1) }
  ppg.ppg_info_mode      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
end

Factory.define :ppg4_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_status         { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Other Probability - Not Pregnant and not Trying", :local_code => 4) }
  ppg.ppg_info_source    { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Person/Self", :local_code => 1) }
  ppg.ppg_info_mode      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
end

Factory.define :ppg5_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_status         { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 5: Ineligible (Unable to Conceive, age-ineligible)", :local_code => 5) }
  ppg.ppg_info_source    { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Person/Self", :local_code => 1) }
  ppg.ppg_info_mode      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
end

Factory.define :ppg6_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu                { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
  ppg.ppg_status         { |a| a.association(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 6: Withdrawn", :local_code => 6) }
  ppg.ppg_info_source    { |a| a.association(:ncs_code, :list_name => "INFORMATION_SOURCE_CL3", :display_text => "Person/Self", :local_code => 1) }
  ppg.ppg_info_mode      { |a| a.association(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1) }
end