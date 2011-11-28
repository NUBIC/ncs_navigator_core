namespace :setup do
  desc "Load all surveys in Rails.root/surveys"
  task :surveys => :environment do
    Dir["#{Rails.root}/surveys/*.rb"].each do |f|
      puts "---   Parsing survey #{f}"
      Surveyor::Parser.parse File.read(f)
      puts "--- Completed survey #{f}"
    end
  end
end
