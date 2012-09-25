begin
  require 'rspec/core/rake_task'

  namespace :spec do
    desc "Run non-warehouse specs"
    RSpec::Core::RakeTask.new(:core) do |t|
      t.pattern = "spec/**/*_spec.rb"
      t.rspec_opts = "-t ~warehouse"
    end
  end
rescue LoadError => e
  desc 'RSpec dependencies missing'
  task :spec do
    $stderr.puts "One or more dependencies not available. RSpec will not work."
    $stderr.puts "#{e.class}: #{e}"
  end
end
