# -*- coding: utf-8 -*-
class PbsListImporter

  def self.import_data(pbs_list_file)
    Rails.application.csv_impl.parse(pbs_list_file, :headers => true, :header_converters => :symbol) do |row|
      next if row.header_row? || row[:provider_id].blank?

      provider = Provider.find_or_create_by_provider_id_and_psu_code(row[:provider_id], row[:psu_id])
      provider.update_attribute(:name_practice, row[:name_practice]) unless row[:name_practice].blank?

      pbs_list = PbsList.find_or_create_by_pbs_list_id_and_provider_id_and_psu_code(
        row[:pbs_list_id], provider.id, row[:psu_id])

      populate_pbs_list_attributes(pbs_list, row)
      populate_pbs_list_ncs_coded_attributes(pbs_list, row)

      create_provider_address(provider, row)

      create_institute(provider) if birthing_center?(pbs_list)

      if pbs_list.valid?
        pbs_list.save!
      else
        # TODO: this is pretty questionable. If there are errors, why not just
        # report them out to the UI?
        File.open(pbs_list_import_error_log, 'a') {|f| f.write("[#{Time.now.to_s(:db)}] pbs_list record invalid for - #{row} - #{pbs_list.errors.map { |e| e.to_s }}\n") }
      end

    end
  end

  def self.pbs_list_import_error_log
    dir = "#{Rails.root}/log/pbs_list_import_error_logs"
    FileUtils.makedirs(dir) unless File.exists?(dir)
    log_path = "#{dir}/#{Date.today.strftime('%Y%m%d')}_import_errors.log"
    File.open(log_path, 'w') {|f| f.write("[#{Time.now.to_s(:db)}] \n\n") } unless File.exists?(log_path)
    log_path
  end

  def self.populate_pbs_list_attributes(pbs_list, row)
    [ :practice_num,
      :mos,
      :stratum,
      :sort_var1,
      :sort_var2,
      :sort_var3,
      :frame_order,
      :selection_probability_location,
      :sampling_interval_woman,
      :selection_probability_woman,
      :selection_probability_overall,
      :pr_recruitment_start_date,
      :pr_cooperation_date,
      :pr_recruitment_end_date
    ].each do |attribute|
      pbs_list.send("#{attribute}=", row[attribute]) unless row[attribute].blank?
    end
  end

  def self.populate_pbs_list_ncs_coded_attributes(pbs_list, row)
    [ :in_out_frame,
      :in_sample,
      :in_out_psu,
      :cert_flag,
      :pr_recruitment_status,
      :frame_completion_req
    ].each do |attribute|
      pbs_list.send("#{attribute}_code=", row[attribute]) unless row[attribute].blank?
    end
  end

  def self.create_provider_address(provider, row)
    address = Address.new(:provider => provider, :address_rank_code => 1)
    [
      [:practice_address, :address_one, 100],
      [:practice_unit,    :unit,        10],
      [:practice_city,    :city,        50],
      [:practice_state,   :state_code,  nil],
      [:practice_zip,     :zip,         5],
      [:practice_zip4,    :zip4,        4]
    ].each do |row_attr, model_attr, max_len|
      val = row[row_attr].to_s
      val = val[0, max_len] if max_len && val.length > max_len
      Rails.logger.info("~~~ #{val}, #{model_attr}, #{max_len}, #{val.length}")
      address.send("#{model_attr}=", val) unless val.blank?
    end
    address.save!
  end

  def self.create_institute(provider)
    institution = Institution.new(:institute_info_date => Date.today,
                                  :institute_info_update => Date.today)
    institution.institute_name = provider.to_s
    institution.institute_type_code = 1 # Birthing Center
    institution.save!

    provider.institution = institution
    provider.save!
  end

  ##
  # Create Institution Record for Provider if the Provider is a Birthing Center
  # i.e. in_out_frame_code on pbs_list is 4 or 5
  #
  # INOUT_FRAME_CL1
  # 1 Provider location in final sampling frame; in scope for screening women from provider location sample and birth sample
  # 2 Provider location in final sampling frame; in scope for screening women from provider location sample only
  # 3 Provider location not in final sampling frame; out of scope for screening
  # 4 Hospital in final sampling frame; out of scope for screening
  # 5 Hospital not in final sampling frame; out of scope for screening
  def self.birthing_center?(pbs_list)
    [4,5].include? pbs_list.in_out_frame_code.to_i
  end

end
