namespace :pbs do

  require File.expand_path("../../pbs_code_list_loader", __FILE__)
  task :codes => :environment do |t|
    PbsCodeListLoader.load_codes
  end

end