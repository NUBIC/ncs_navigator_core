namespace :monit do
  namespace :config do
    desc 'Generate the monit configuration for Core'
    task :generate do
      raise "Failed: Please specify the rails environment monit will run in (eg. RAILS_ENV='staging')" if ENV['RAILS_ENV'].blank?
      require 'erb'
      PWD = ENV['PWD']
      CONFIG_TEMPLATE = File.join(PWD, 'monit.cfg.erb')
      templ = ERB.new(File.read(CONFIG_TEMPLATE))
      CONFIG = File.join(PWD, 'monit.cfg')
      File.open(CONFIG, 'w') {|f| f.write(templ.result) }
    end
  end
end
