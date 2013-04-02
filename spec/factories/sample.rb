# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :sample_receipt_store do |srs|
    srs.psu_code                              20000030
    srs.association :sample, :factory => :sample
    srs.association :sample_receipt_shipping_center, :factory => :sample_receipt_shipping_center
    srs.staff_id                              {"staff1234"}
    srs.sample_condition_code                 1
    srs.receipt_comment_other                 nil
    srs.receipt_datetime                      Date.today
    srs.cooler_temp_condition_code            1
    srs.association :environmental_equipment, :factory => :environmental_equipment
    srs.placed_in_storage_datetime            Date.today
    srs.storage_compartment_area_code         1
    srs.storage_comment_other                 nil
    srs.removed_from_storage_datetime         Date.today
    srs.temp_event_occurred_code              1
    srs.temp_event_action_code                1
    srs.temp_event_action_other               nil
    srs.transaction_type                      nil
  end

  factory :sample_receipt_shipping_center do |srsc|
    srsc.psu_code                             20000030
    srsc.sample_receipt_shipping_center_id    {"srsc_id"}
    srsc.association :address, :factory => :address
    srsc.transaction_type                     nil
  end

  factory :environmental_equipment do |ee|
    ee.psu_code                            20000030
    ee.association :sample_receipt_shipping_center, :factory => :sample_receipt_shipping_center
    ee.equipment_id                        {"4567"}
    ee.equipment_type_code                 1
    ee.equipment_type_other                nil
    ee.serial_number                       {"BC12B78DE"}
    ee.government_asset_tag_number         nil
    ee.retired_date                        nil
    ee.retired_reason_code                 1
    ee.retired_reason_other                nil
    ee.transaction_type                    nil
  end

  factory :sample_shipping do |ss|
    ss.psu_code                         20000030
    ss.association :sample_receipt_shipping_center, :factory => :sample_receipt_shipping_center
    ss.staff_id                         {"newStaff123"}
    ss.shipper_id                       {"FEDEX"}
    ss.shipper_destination_code         1
    ss.shipment_date                    {"2012-01-28"}
    ss.shipment_coolant_code            1
    ss.shipment_tracking_number         {"ABCDE234325"}
    ss.shipment_issues_other            nil
    ss.staff_id_track                   {"newStaff123"}
    ss.sample_shipped_by_code           1
    ss.transaction_type                 nil
  end
  
  factory :sample_receipt_confirmation do |src|
    src.psu_code                         20000030
    src.association :sample, :factory => :sample
    src.association :sample_receipt_shipping_center, :factory => :sample_receipt_shipping_center
    src.shipment_receipt_confirmed_code  1
    src.shipper_id                       {"FEDEX"}
    src.association :sample_shipping, :factory => :sample_shipping
    src.shipment_receipt_datetime        Date.today
    src.shipment_condition_code          1
    src.shipment_damaged_reason          nil
    src.sample_receipt_temp              -2.1
    src.sample_condition_code            1
    src.shipment_received_by             "Jane Dow"
    src.transaction_type                 nil
    src.staff_id                         "whateverstaffid"
  end  

  factory :sample do |sa|
    sa.sample_id                        {"SAMPLE123ID"}
    sa.association :instrument,  :factory => :instrument
    sa.association :sample_shipping, :factory => :sample_shipping
    sa.volume_amount                    nil
    sa.volume_unit                      nil
  end
end
