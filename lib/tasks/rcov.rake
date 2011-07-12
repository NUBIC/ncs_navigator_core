begin
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'

  namespace :rcov do
    
    rcov_options = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/ --aggregate coverage.data}
    
    Cucumber::Rake::Task.new(:cucumber_run) do |t|
      t.rcov = true
      t.rcov_opts = rcov_options
      t.rcov_opts << %[-o "coverage"]
    end
  
    RSpec::Core::RakeTask.new(:rspec_run) do |t|
      t.pattern = FileList['spec/**/*_spec.rb']
      t.rcov = true
      t.rcov_opts = rcov_options
    end

    task :clean do |t|
      rm "coverage.data" if File.exist?("coverage.data")
    end

    desc "Run both specs and features to generate aggregated coverage"
    task :all do |t|
      Rake::Task["rcov:clean"].invoke
      Rake::Task["rcov:rspec_run"].invoke
      Rake::Task["rcov:cucumber_run"].invoke
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
rescue
  desc 'ci rake task not available (cucumber or rspec not installed)'
  task :ci do
    abort 'CI rake task is not available. Be sure to install cucumber and/or rspec as a gem or plugin'
  end
end