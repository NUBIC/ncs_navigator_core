begin
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'

  namespace :rcov do

    rcov_options = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/ --aggregate coverage/coverage.data}


    Cucumber::Rake::Task.new(:cucumber_run) do |t|
      t.cucumber_opts = "--format pretty"
      t.rcov = true
      t.rcov_opts = rcov_options
      t.rcov_opts << %[-o "coverage"]
    end

    RSpec::Core::RakeTask.new(:rspec_run) do |t|
      t.spec_opts = ["--color --format nested -t ~slow"]
      t.pattern = FileList['spec/**/*_spec.rb']
      t.rcov = true
      t.rcov_opts = rcov_options
    end

    task :clean do |t|
      rm "coverage/coverage.data" if File.exist?("coverage/coverage.data")
    end

    desc "Run both specs and features to generate aggregated coverage"
    task :all do |t|
      Rake::Task["rcov:clean"].invoke
      puts "~~~ running cucumber features"
      Rake::Task["rcov:cucumber_run"].invoke
      puts "~~~ running rspecs"
      Rake::Task["rcov:rspec_run"].invoke
    end

    desc "Run only rspecs"
    task :rspec do |t|
      Rake::Task["rcov:clean"].invoke
      Rake::Task["rcov:rspec_run"].invoke
    end

    desc "Run only cucumber"
    task :cucumber do |t|
      Rake::Task["rcov:clean"].invoke
      Rake::Task["rcov:cucumber_run"].invoke
    end

  end
rescue LoadError => e
  desc 'rcov dependencies missing'
  task :rcov do
    $stderr.puts "One or more dependencies not available. RCOV will not work.\n#{e.class}: #{e}"
  end
end
