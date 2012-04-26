FactoryGirl.define do
  factory :sample_receipt_store do |srs|
    srs.psu                                   { |a| a.association(:ncs_code, :list_name => "PSU_CL1")}
    srs.sample_id                             {"1234567"}
    srs.association :sample_receipt_shipping_center, :factory => :sample_receipt_shipping_center
    srs.staff_id                              {"staff1234"}
    srs.sample_condition                      {|a| a.association(:ncs_code, :list_name => "SPECIMEN_STATUS_CL7", :local_code => 1)}
    srs.receipt_comment_other                 nil
    srs.receipt_datetime                      Date.today
    srs.cooler_temp_condition                 {|a| a.association(:ncs_code, :list_name => "COOLER_TEMP_CL1", :local_code => 1)}
    srs.association :environmental_equipment, :factory => :environmental_equipment
    srs.placed_in_storage_datetime            Date.today
    srs.storage_compartment_area              {|a| a.association(:ncs_code, :list_name => "STORAGE_AREA_CL2", :local_code => 1)}
    srs.storage_comment_other                 nil
    srs.removed_from_storage_datetime         Date.today
    srs.temp_event_occurred                   {|a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL20", :local_code => 1)}
    srs.temp_event_action                     {|a| a.association(:ncs_code, :list_name => "SPECIMEN_STATUS_CL6", :local_code => 1)}
    srs.temp_event_action_other               nil
    srs.transaction_type                      nil
  end
  
  factory :sample_receipt_shipping_center do |srsc|
    srsc.psu_code                             { |a| a.association(:ncs_code, :list_name => "PSU_CL1") }
    srsc.sample_receipt_shipping_center_id    {"555"}
    srsc.association :address, :factory => :address 
    srsc.transaction_type                     nil
  end
  
  factory :environmental_equipment do |ee|
    ee.psu                                 { |a| a.association(:ncs_code, :list_name => "PSU_CL1")}
    ee.association :sample_receipt_shipping_center, :factory => :sample_receipt_shipping_center
    ee.equipment_id                        {"4567"}
    ee.equipment_type                      {|a| a.association(:ncs_code, :list_name => "EQUIPMENT_TYPE_CL2", :local_code => 1)}
    ee.equipment_type_other                nil
    ee.serial_number                       {"BC12B78DE"}
    ee.government_asset_tag_number         nil
    ee.retired_date                        nil
    ee.retired_reason                      {|a| a.association(:ncs_code, :list_name => "EQUIPMENT_ISSUES_CL1", :local_code => 1)}
    ee.retired_reason_other                nil
    ee.transaction_type                    nil
  end

  factory :sample_shipping do |ss|
    ss.psu                              { |a| a.association(:ncs_code, :list_name => "PSU_CL1")}
    ss.sample_id                        {"SAMPLE123ID"}
    ss.association :sample_receipt_shipping_center, :factory => :sample_receipt_shipping_center
    ss.staff_id                         {"newStaff123"}
    ss.shipper_id                       {"FEDEX"}
    ss.shipper_destination              { |a| a.association(:ncs_code, :list_name => "SHIPPER_DESTINATION_CL1", :local_code => 1, :display_text => "Vacuum Bag Dust Processing Lab")}
    ss.shipment_date                    {"2012-01-28"}
    ss.shipment_coolant                 { |a| a.association(:ncs_code, :list_name => "SHIPMENT_TEMPERATURE_CL2", :local_code => 1, :display_text => "Dry Ice")}
    ss.shipment_tracking_number         {"ABCDE234325"}
    ss.shipment_issues_other            nil
    ss.staff_id_track                   nil
    ss.sample_shipped_by                { |a| a.association(:ncs_code, :list_name => "SAMPLES_SHIPPED_BY_CL1")}
    ss.transaction_type                 nil
  end
  
  factory :sample do |sa|
    sa.sample_id                        {"SAMPLE123ID"}
    sa.association :instrument,  :factory => :instrument
  end 
end    
