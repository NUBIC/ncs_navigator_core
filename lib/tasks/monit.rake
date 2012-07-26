namespace :monit do
  namespace :config do
    desc 'Generate the monit configuration for Core'
    task :generate do
      require 'erb'
      File.open(generated_config_path, 'w') do |f|
        out = ERB.new(File.read(template_path)).result(context.instance_eval { binding })
        f.write(out)
      end
    end

    def template_path
      File.join(ENV['PWD'], 'monit.cfg.erb')
    end

    def context
      OpenStruct.new(
        { :rails_env => (ENV['RAILS_ENV'].blank? ? Rails.env : ENV['RAILS_ENV']), :pwd => ENV['PWD']})
    end

    def generated_config_path
      File.join(ENV['PWD'], 'monit.cfg')
    end
  end
end
