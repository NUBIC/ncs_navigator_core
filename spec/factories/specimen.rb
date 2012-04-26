FactoryGirl.define do
  
  factory :specimen_pickup do |sp|
    sp.psu                              { |a| a.association(:ncs_code, :list_name => "PSU_CL1", :local_code => 1)}
    sp.association :specimen_processing_shipping_center, :factory => :specimen_processing_shipping_center
    sp.association :event, :factory => :event
    sp.staff_id                              {"staff123"}
    sp.specimen_pickup_datetime              Date.today
    sp.specimen_pickup_comment_code          {|a| a.association(:ncs_code, :list_name => "SPECIMEN_STATUS_CL5", :local_code => 1)}
    sp.specimen_pickup_comment_other         nil
    sp.specimen_transport_temperature        {"21.2"}
    sp.transaction_type                      nil
  end

  factory :specimen do |s|
    s.association :specimen_pickup,  :factory => :specimen_pickup
    s.specimen_id                           {"AAA10001AA20"}  
    s.instrument_id                         {"instrument123"}
  end  
  
  factory :specimen_receipt do |sr|
    sr.psu                                   { |a| a.association(:ncs_code, :list_name => "PSU_CL1")}
    sr.specimen_id                           {"10001"}
    sr.association :specimen_processing_shipping_center, :factory => :specimen_processing_shipping_center
    sr.staff_id                              {"staff123"}
    sr.receipt_comment                       {|a| a.association(:ncs_code, :list_name => "SPECIMEN_STATUS_CL3", :local_code => 1)}
    sr.receipt_comment_other                 nil
    sr.receipt_datetime                      Date.today
    sr.cooler_temp                           nil
    sr.monitor_status                        {|a| a.association(:ncs_code, :list_name => "TRIGGER_STATUS_CL1", :local_code => 1)}
    sr.upper_trigger                         {|a| a.association(:ncs_code, :list_name => "TRIGGER_STATUS_CL1", :local_code => 1)}
    sr.upper_trigger_level                   {|a| a.association(:ncs_code, :list_name => "TRIGGER_STATUS_CL2", :local_code => 1)}
    sr.lower_trigger_cold                    {|a| a.association(:ncs_code, :list_name => "TRIGGER_STATUS_CL1", :local_code => 1)}
    sr.lower_trigger_ambient                 {|a| a.association(:ncs_code, :list_name => "TRIGGER_STATUS_CL1", :local_code => 1)}
    sr.storage_container_id                  {"ABC123"}
    sr.centrifuge_comment                    {|a| a.association(:ncs_code, :list_name => "SPECIMEN_STATUS_CL4", :local_code => 1)}
    sr.centrifuge_comment_other              nil
    sr.centrifuge_starttime                  nil
    sr.centrifuge_endtime                    nil
    sr.centrifuge_staff_id                   nil
    sr.association :specimen_equipment, :factory => :specimen_equipment
    sr.transaction_type                      nil
  end
  
  factory :specimen_processing_shipping_center do |spsc|
    spsc.psu_code                            { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
    spsc.specimen_processing_shipping_center_id      {"234"}
    spsc.association :address, :factory => :address 
    spsc.transaction_type                    nil
  end
  
  factory :specimen_equipment do |ee|
    ee.psu                                   { |a| a.association(:ncs_code, :list_name => "PSU_CL1")}
    ee.association :specimen_processing_shipping_center, :factory => :specimen_processing_shipping_center
    ee.equipment_id                          {"4567"}
    ee.equipment_type                        {|a| a.association(:ncs_code, :list_name => "EQUIPMENT_TYPE_CL2", :local_code => 1)}
    ee.equipment_type_other                  nil
    ee.serial_number                         {"A12B78D"}
    ee.government_asset_tag_number           nil
    ee.retired_date                          nil
    ee.retired_reason                        {|a| a.association(:ncs_code, :list_name => "EQUIPMENT_ISSUES_CL1", :local_code => 1)}
    ee.retired_reason_other                  nil
    ee.transaction_type                      nil
  end
  
  factory :specimen_shipping do |ss|
    ss.psu                                  { |a| a.association(:ncs_code, :list_name => "PSU_CL1")}
    ss.storage_container_id                 {"A123B"}
    ss.association :specimen_processing_shipping_center, :factory => :specimen_processing_shipping_center 
    ss.staff_id                             {"newStaff123"}
    ss.shipper_id                           {"FEDEX"}
    ss.shipper_destination                  {"LAB"}
    ss.shipment_date                        {"2012-01-28"}
    ss.shipment_temperature                 { |a| a.association(:ncs_code, :list_name => "SHIPMENT_TEMPERATURE_CL1", :local_code => 1)}
    ss.shipment_tracking_number             {"AWQ1890XYZ509"}
    ss.shipment_receipt_confirmed           { |a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2")}
    ss.shipment_receipt_datetime            nil
    ss.shipment_issues                      { |a| a.association(:ncs_code, :list_name => "SHIPMENT_ISSUES_CL1")}
    ss.shipment_issues_other                nil
    ss.transaction_type                     nil
  end
  
  factory :specimen_storage do |ss|
    ss.psu                                  { |a| a.association(:ncs_code, :list_name => "PSU_CL1")}
    ss.storage_container_id                 {"ABC123DEF"}
    ss.association :specimen_processing_shipping_center, :factory => :specimen_processing_shipping_center 
    ss.staff_id                             {"great personel"}
    ss.placed_in_storage_datetime           Date.today
    ss.specimen_equipment_id                nil
    ss.master_storage_unit_code             { |a| a.association(:ncs_code, :list_name => "STORAGE_AREA_CL1", :local_code => 1)}
    ss.storage_comment                      {"SOME FANSY COMMENT"}
    ss.storage_comment_other                nil
    ss.removed_from_storage_datetime        nil
    ss.temp_event_starttime                 nil
    ss.temp_event_endtime                   nil
    ss.temp_event_low_temp                  nil    
    ss.temp_event_high_temp                 nil
    ss.transaction_type                     nil
  end
end    
    