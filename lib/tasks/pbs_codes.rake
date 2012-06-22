namespace :pbs do

    task :codes => :environment do |t|
      PbsCodeListLoader.load_codes
    end

end