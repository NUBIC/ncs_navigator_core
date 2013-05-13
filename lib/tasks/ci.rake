begin
  require 'ci/reporter/rake/rspec'
  require 'rspec/core/rake_task'
  require 'cucumber/rake/task'

  namespace :ci do
    desc 'Run full CI build'
    task :all => [:rails_env, :spec, :cucumber]

    desc 'Run CI build minus warehouse specs'
    task :core => [:rails_env, 'ci:redis:start_then_stop_at_exit', :spec_core, :cucumber]

    desc 'Run CI build minus warehouse specs and redis'
    task :core_no_redis => [:rails_env, :spec_core, :cucumber]

    desc 'Run CI build for warehouse only'
    task :warehouse => [:rails_env, 'ci:redis:start_then_stop_at_exit', :spec_warehouse]

    task :setup => [:clear_log, :navigator_configuration, 'db:migrate']

    # CI tasks should be run through the ci-exec.sh script.
    # If they are accidentally run directly, we want to
    # make sure the RAILS_ENV is 'ci'. This prevents the
    # development database from being clobbered by the tests.
    task :rails_env do
      ENV["RAILS_ENV"] ||= 'ci'
    end

    # Initializes NcsNavigator.configuration in an
    # environment-independent way.
    task :navigator_configuration do
      require 'ncs_navigator/configuration'
      NcsNavigator.configuration = NcsNavigator::Configuration.new(
        File.expand_path('../../../spec/navigator.ini', __FILE__))
    end

    desc "Completely clears the log directory"
    # Needed because the Rails built-in log:clear does not 1) traverse subdirs
    # and 2) actually remove files. Actually removing files reduces clutter in
    # the archived CI builds — it makes it true that archived logs for a build
    # are only the logs produced when running that specific build.
    task :clear_log do
      log_dir = Rails.root + 'log'
      if log_dir.exist?
        log_dir.each_child do |sub|
          rm_rf sub.to_s
        end
      end
    end

    task :spec_setup do
      ENV['CI_REPORTS'] = 'reports/spec-xml'
      ENV['SPEC_OPTS'] = "#{ENV['SPEC_OPTS']} --format nested"
    end

    desc "Run specs for CI (i.e., without db:test:prepare)"
    RSpec::Core::RakeTask.new(:spec => [:setup, :spec_setup, 'ci:setup:rspecbase', 'db:test:prepare:warehouse']) do |t|
      t.pattern = "spec/**/*_spec.rb"
    end

    desc "Run non-warehouse specs for CI (i.e., without db:test:prepare)"
    RSpec::Core::RakeTask.new(:spec_core => [:setup, :spec_setup, 'ci:setup:rspecbase']) do |t|
      t.pattern = "spec/**/*_spec.rb"
      t.rspec_opts = "-t ~warehouse"
    end

    desc "Run warehouse specs for CI"
    RSpec::Core::RakeTask.new(:spec_warehouse => [:setup, :spec_setup, 'ci:setup:rspecbase', 'db:test:prepare:warehouse']) do |t|
      t.pattern = "spec/**/*_spec.rb"
      t.rspec_opts = "-t warehouse"
    end

    Cucumber::Rake::Task.new(
      { :cucumber => [:setup] }, 'Run features for CI (without database setup steps)'
      ) do |t|
      t.fork = true
      t.profile = 'ci'
    end

    namespace :redis do
      REDIS_DIR = File.expand_path('../../../tmp/redis-for-ci', __FILE__)
      REDIS_PIDFILE = File.join(REDIS_DIR, 'pid')
      REDIS_LOGFILE = File.join(REDIS_DIR, 'log')
      REDIS_STARTUP_TIMEOUT = 15

      def random_port
        require 'socket'
        while true
          candidate = rand(63000) + 2000
          begin
            TCPSocket.new('127.0.0.1', candidate).close
          rescue Errno::ECONNREFUSED
            return candidate
          end
        end
      end

      desc "Start Redis for CI"
      task :start => :fail_if_running do
        mkdir_p REDIS_DIR
        redis_server = ENV['REDIS_SERVER_BIN'] || 'redis-server'
        redis_config = File.join(REDIS_DIR, 'conf')
        redis_port = random_port.to_s
        ENV['CI_REDIS_PORT'] = redis_port

        File.open(redis_config, 'w') do |f|
          [
            "daemonize yes",
            "pidfile \"#{REDIS_PIDFILE}\"",
            "port #{redis_port}",
            "logfile \"#{REDIS_LOGFILE}\""
          ].each do |line|
            f.puts line
          end
        end

        if system(redis_server, redis_config)
          waited = 0
          until File.exist?(REDIS_PIDFILE) || waited >= REDIS_STARTUP_TIMEOUT
            waited += 0.5
            sleep 0.5
          end
          if waited >= REDIS_STARTUP_TIMEOUT
            fail "Redis pidfile never showed up"
          else
            $stderr.puts "Redis started on #{redis_port} after #{waited}s"
          end
        else
          fail "Redis did not start"
        end
      end

      task :fail_if_running do
        if File.exist?(REDIS_PIDFILE)
          redis_pid = File.read(REDIS_PIDFILE).chomp
          fail "Redis seems to be already running (pid=#{redis_pid}).
If it's not, remove #{REDIS_PIDFILE} and try again."
        end
      end

      desc "Start Redis for CI and ensure that it only runs for the duration of the rake run"
      task :start_then_stop_at_exit => :start do
        at_exit do
          task('ci:redis:stop').invoke
        end
      end

      desc "Stop Redis for CI"
      task :stop do
        fail "No Redis pidfile #{REDIS_PIDFILE}" unless File.exist?(REDIS_PIDFILE)

        redis_pid = File.read(REDIS_PIDFILE).chomp
        $stderr.puts "Terminating Redis pid=#{redis_pid}"
        unless system('kill', redis_pid)
          fail "Could not kill Redis process #{REDIS_PIDFILE}"
        end
      end
    end
  end
rescue LoadError => e
  desc 'CI dependencies missing'
  task :ci do
    $stderr.puts "One or more dependencies not available. CI builds will not work."
    $stderr.puts "#{e.class}: #{e}"
  end
end
