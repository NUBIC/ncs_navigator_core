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

  task :set_whodunnit do
    PaperTrail.whodunnit = ['rake', ARGV].flatten.join(' ')
  end

  desc 'Clones a single case'
  task :clone_case, [:p_id, :n] => ['import:psc_setup', :environment, :set_whodunnit] do |t, args|
    psc_user = task('import:psc_setup').user
    p_id = args[:p_id] or fail "Please specify a p_id: rake #{t.name}[12-1234]"
    n = args[:n].try(:to_i) || 1
    digits = (Math.log(n, 10) + 1).to_i

    1.upto(n) do |i|
      $stderr.print "(%#{digits}d/%d) Cloning #{p_id} and any related participants..." % [i, n]
      result = NcsNavigator::Core::CaseCloner.new(p_id).clone(psc_user)
      $stderr.puts "done."

      result.each do |source, clone|
        $stderr.puts "  #{source.p_id} cloned as #{clone.p_id}"
      end
    end
  end
end
