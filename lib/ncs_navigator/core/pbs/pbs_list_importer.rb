class PbsListImporter

  def self.import_data(pbs_list_file)
    FasterCSV.parse(pbs_list_file, :headers => true, :header_converters => :symbol) do |row|
      next if row.header_row?

      provider = find_or_create_provider(row)
      substitute_provider = Provider.where(:provider_id => row[:substitute_provider_id]).first

      pbs_list = PbsList.new(:psu_code => row[:psu_id], :provider => provider, :substitute_provider => substitute_provider)

      populate_pbs_list_attributes(pbs_list, row)
      populate_pbs_list_ncs_coded_attributes(pbs_list, row)

      create_provider_address(provider, row)

      if pbs_list.valid?
        pbs_list.save!
      else
        File.open(pbs_list_import_error_log, 'a') {|f| f.write("[#{Time.now.to_s(:db)}] pbs_list record invalid for - #{row} - #{pbs_list.errors.map(&:to_s)}\n") }
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

  def self.find_or_create_provider(row)
    provider = Provider.where(:provider_id => row[:provider_id]).first

    if provider.nil?
      provider = Provider.new(:name_practice => row[:name_practice], :provider_id => row[:provider_id])
    else
      provider.name_practice = row[:name_practice]
    end

    provider.save!
    provider
  end

  def self.create_provider_address(provider, row)
    address = Address.new(:provider => provider)
    [
      [:practice_address, :address_one],
      [:practice_unit,    :unit],
      [:practice_city,    :city],
      [:practice_state,   :state_code],
      [:practice_zip,     :zip],
      [:practice_zip4,    :zip4]
    ].each do |row_attr, model_attr|
      address.send("#{model_attr}=", row[row_attr]) unless row[row_attr].blank?
    end
    address.save!
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
      :selection_probability_overall
    ].each do |attribute|
      pbs_list.send("#{attribute}=", row[attribute]) unless row[attribute].blank?
    end
  end

  def self.populate_pbs_list_ncs_coded_attributes(pbs_list, row)
    [ :in_out_frame,
      :in_sample,
      :in_out_psu,
      :cert_flag,
      :frame_completion_req
    ].each do |attribute|
      pbs_list.send("#{attribute}_code=", row[attribute]) unless row[attribute].blank?
    end
  end

end