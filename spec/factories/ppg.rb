# -*- coding: utf-8 -*-

Factory.define :ppg_detail do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_pid_status_code     3
  ppg.ppg_first_code          2
  ppg.orig_due_date      nil
end

Factory.define :ppg1_detail, :class => PpgDetail do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_pid_status_code     3
  ppg.ppg_first_code          1
  ppg.orig_due_date      6.months.from_now.strftime("%Y-%m-%d")
  ppg.created_at         Time.now
end

Factory.define :ppg2_detail, :class => PpgDetail do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_pid_status_code     3
  ppg.ppg_first_code          2
  ppg.orig_due_date      nil
end

Factory.define :ppg_status_history do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_status_code         1
  ppg.ppg_info_source_code    1
  ppg.ppg_info_mode_code      1
  ppg.ppg_status_date    '2011-01-01'
end

Factory.define :ppg1_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_status_code         1
  ppg.ppg_info_source_code    1
  ppg.ppg_info_mode_code      1
end

Factory.define :ppg2_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_status_code         2
  ppg.ppg_info_source_code    1
  ppg.ppg_info_mode_code      1
end

Factory.define :ppg3_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_status_code         3
  ppg.ppg_info_source_code    1
  ppg.ppg_info_mode_code      1
end

Factory.define :ppg4_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_status_code         4
  ppg.ppg_info_source_code    1
  ppg.ppg_info_mode_code      1
end

Factory.define :ppg5_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_status_code         5
  ppg.ppg_info_source_code    1
  ppg.ppg_info_mode_code      1
end

Factory.define :ppg6_status, :class => PpgStatusHistory do |ppg|
  ppg.association :participant,  :factory => :participant
  ppg.psu_code                2000030
  ppg.ppg_status_code         6
  ppg.ppg_info_source_code    1
  ppg.ppg_info_mode_code      1
end
