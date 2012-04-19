namespace :setup do
  desc "Load all surveys in Rails.root/surveys"
  task :surveys => :environment do
    if File.exists? "#{Rails.root}/surveys/"
      Dir["#{Rails.root}/surveys/*.rb"].each do |f|
        puts "---   Parsing survey #{f}"
        Surveyor::Parser.parse File.read(f)
        puts "--- Completed survey #{f}"
      end
    else
      puts "WARNING: #{Rails.root}/surveys/ directory does not exist."
      puts "         Please place NCS surveys in #{Rails.root}/surveys/ directory."
    end
  end

  desc 'Checks for syntax errors in the surveys'
  task :survey_syntax do
    errors = false
    Dir['surveys/*.rb'].each do |file|
      Bundler.with_clean_env do
        # sh fails on the first one with a problem, so use system
        puts "Checking #{file}"
        system "ruby -c '#{file}'"
      end
      errors ||= ($? != 0)
    end
    if errors
      fail 'One or more instruments have syntax errors. See above for details.'
    else
      puts 'All surveys are syntactically valid ruby.'
    end
  end
end
