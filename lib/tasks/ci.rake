begin
  require 'ci/reporter/rake/rspec'
  require 'rspec/core/rake_task'
  require 'cucumber/rake/task'

  namespace :ci do
    desc 'Run full CI build'
    task :all => [:spec, :cucumber]

    desc 'Run CI build minus warehouse specs'
    task :core => [:spec_core, :cucumber]

    task :setup => ['log:clear', :navigator_configuration, 'db:migrate']

    # Initializes NcsNavigator.configuration in an
    # environment-independent way.
    task :navigator_configuration do
      require 'ncs_navigator/configuration'
      NcsNavigator.configuration = NcsNavigator::Configuration.new(
        File.expand_path('../../../spec/navigator.ini', __FILE__))
    end

    task :spec_setup do
      ENV['CI_REPORTS'] = 'reports/spec-xml'
      ENV['SPEC_OPTS'] = "#{ENV['SPEC_OPTS']} --format nested"
    end

    desc "Run specs for CI (i.e., without db:test:prepare)"
    RSpec::Core::RakeTask.new(:spec => [:setup, :spec_setup, 'ci:setup:rspecbase']) do |t|
      t.pattern = "spec/**/*_spec.rb"
    end

    desc "Run non-warehouse specs for CI (i.e., without db:test:prepare)"
    RSpec::Core::RakeTask.new(:spec_core => [:setup, :spec_setup, 'ci:setup:rspecbase']) do |t|
      t.pattern = "spec/**/*_spec.rb"
      t.rspec_opts = "-t ~warehouse"
    end

    Cucumber::Rake::Task.new(
      { :cucumber => [:setup] }, 'Run features for CI (without database setup steps)'
      ) do |t|
      t.fork = true
      t.profile = 'ci'
    end
  end
rescue LoadError => e
  desc 'CI dependencies missing'
  task :ci do
    $stderr.puts "One or more dependencies not available. CI builds will not work."
    $stderr.puts "#{e.class}: #{e}"
  end
end
