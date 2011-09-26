namespace :setup do    
  
  desc "Run rake surveys FILE=surveys/xxx for all files in Rails.root/surveys"
  task :surveys => :environment do
    Dir.foreach("#{Rails.root}/surveys") do |f|
      `rake surveyor FILE=surveys/#{f}` unless File.directory?(f)
    end
  end
end