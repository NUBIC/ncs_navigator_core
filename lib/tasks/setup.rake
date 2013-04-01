namespace :setup do
  desc "Load all surveys in Rails.root/surveys and Rails.root/internal_surveys"
  task :surveys => :environment do
    %w(surveys internal_surveys).each do |dir|
      if File.exists? "#{Rails.root}/#{dir}/"
        Dir["#{Rails.root}/#{dir}/*.rb"].each do |f|
          puts "---   Parsing survey #{f}"
          Surveyor::Parser.parse_file f
          puts "--- Completed survey #{f}"
        end
      else
        puts "WARNING: #{Rails.root}/#{dir}/ directory does not exist."
        puts "         Please place NCS surveys in #{Rails.root}/#{dir}/ directory."
      end
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
