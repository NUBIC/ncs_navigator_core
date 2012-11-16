namespace 'db:backup' do
  desc "Dumps Cases' and PSC's databases using pg_dump -Fc; backup name defaults to timestamp."
  task :dump, [:backup_name] => [:environment, :tmp_pgpass] do |t, args|
    backup_name ||= args[:backup_name] || generate_timestamp_name
    backup_path = backup_path(backup_name)
    fail "There is already a backup named #{backup_name}." if backup_path.exist?
    backup_path.mkpath

    db_backup_params.each do |name, params|
      dump_file = backup_path + "#{name}.dump"
      $stderr.puts "Backing up #{name} to #{dump_file}."
      db_do_dump(params, dump_file)
    end
  end

  desc 'Restores both the Cases and PSC databases.'
  task :restore, [:backup_name] => [:environment, :tmp_pgpass] do |t, args|
    backup_path = backup_path(args[:backup_name] || fail("Please specify a backup name as a task arg."))
    unless backup_path.exist?
      $stderr.puts "No backup #{args[:backup_name]}."
      if backup_path.parent.exist?
        backups = backup_path.parent.children.select { |e| e.directory? }
        if backups.empty?
          $stderr.puts "No backups present."
        else
          $stderr.puts "Found backups:"
          backups.each do |backup|
            $stderr.puts "* #{backup.basename}"
          end
        end
      end
      exit(1)
    end

    db_backup_params.each do |name, params|
      dump_file = backup_path + "#{name}.dump"
      $stderr.puts "Restoring #{name} from #{dump_file}"
      db_do_restore(params, dump_file)
    end
  end

  def backup_path(backup_name)
    require 'pathname'

    Pathname.new(File.join('db', 'backups', backup_name))
  end

  def generate_timestamp_name
    require 'time'

    Time.now.strftime("#{Rails.env}_%Y%m%d_%H%M")
  end

  def db_do_dump(params, filename=nil)
    dump_command = ['pg_dump', '-Fc']
    dump_command << '-h' << params['host'] if params['host']
    dump_command << '-p' << params['port'] if params['port']
    dump_command << '-U' << params['username']
    dump_command << '-f' << filename if filename
    dump_command << params['database']

    if filename
      sh(dump_command.join(' '))
    else
      system(dump_command.join(' '))
    end
  end

  def db_do_restore(params, filename=nil)
    restore_command = ['pg_restore', '--clean', '--no-owner', '--schema=public']
    restore_command << '-h' << params['host'] if params['host']
    restore_command << '-p' << params['port'] if params['port']
    restore_command << '-U' << params['username']
    restore_command << '-d' << params['database']
    restore_command << filename if filename

    if filename
      sh(restore_command.join(' '))
    else
      system(restore_command.join(' '))
    end
  end

  def db_backup_params
    @db_backup_params ||= {
      :cases => ActiveRecord::Base.configurations[Rails.env],
      :psc   => ActiveRecord::Base.configurations["psc_#{Rails.env}"]
    }
  end

  # Sets up a temporary pgpass file for the current env
  task :tmp_pgpass => :environment do |t|
    require 'tempfile'
    class << t; attr_accessor :tempfile; end

    t.tempfile = Tempfile.new('cases-backup-pgpass')
    db_backup_params.values.each do |params|
      t.tempfile.puts [
        params['host'] || 'localhost',
        params['port'] || '*',
        '*',
        params['username'],
        params['password']
      ].join(':')
    end
    t.tempfile.close

    $stderr.puts "Temporary pgpass created at #{t.tempfile.path}" if Rake.application.options.trace
    ENV['PGPASSFILE'] = t.tempfile.path
  end
end
