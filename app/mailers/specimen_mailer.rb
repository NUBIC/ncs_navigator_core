# -*- coding: utf-8 -*-
class SpecimenMailer < ActionMailer::Base
  def manifest_email(params)
    from_email = params[:from_email]
    to_email = NcsNavigatorCore.configuration.manifest_email_sent_to

    @shipper_id = params[:shipper_id]
    @psu_code = params[:psu_code]
    @specimen_processing_shipping_center_id = params[:specimen_processing_shipping_center_id]
    @sample_receipt_shipping_center_id = params[:sample_receipt_shipping_center_id]
    @contact_name = params[:contact_name]
    @contact_phone = params[:contact_phone]
    @carrier = params[:carrier]
    @shipment_tracking_number = params[:shipment_tracking_number]
    @shipment_date_and_time = params[:shipment_date_and_time]
    @shipper_dest = params[:shipper_dest]
    @scheduled_delivery = 1.day.from_now
    @shipping_temperature_selected = params[:shipping_temperature_selected]
    @total_number_of_containers = params[:total_number_of_containers]
    @total_number_of_samples = params[:total_number_of_samples]

    # NCS-(BIO or ENV)-PSU ID-Carrier-Tracking Number
    @subject = "NCS-" + params[:kind] + "-" + @psu_code.to_s + "-" + @carrier + "-" + @shipment_tracking_number

    content_type "text/html"
    mail(:to => to_email, :subject => @subject, :from => from_email) do |format|
      format.text
      format.html
    end
  end
end

