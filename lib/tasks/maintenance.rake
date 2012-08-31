# Tasks for putting Cases into maintenance mode. The block and unblock tasks
# assume an application server configuration which will react to the existence
# of tmp/stop.txt by blocking access to the application.
namespace :maintenance do
  STOP_FILE = File.expand_path('../../../tmp/stop.txt', __FILE__)

  desc 'Generates the maintenance warning page, optionally with a maintenance window.'
  task :html, [:maintenance_window] do |t, args|
    require 'haml'

    template = File.expand_path('../../../app/views/maintenance.html.haml', __FILE__)
    output = File.expand_path('../../../public/maintenance.html', __FILE__)

    File.open(output, 'w:utf-8') do |f|
      f.write Haml::Engine.new(File.read template).
        render(Object.new, { 'maintenance_window' => args.maintenance_window })
    end
  end

  desc 'Set tmp/stop.txt to block access to the application'
  task :block => :html do
    touch STOP_FILE
  end

  # Regenerates the maintenance.html file so that it returns to its generic (no
  # specified window) state.
  desc 'Restore access to the application'
  task :unblock => :html do
    rm_f STOP_FILE
  end
end
