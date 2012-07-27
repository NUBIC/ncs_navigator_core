namespace :monit do
  namespace :config do
    desc 'Generate the monit configuration for Core'
    task :generate do
      File.open(generated_config_path, 'w') { |f| f.write(ERB.new(template).result(binding)) }
    end

    def template
      File.read(File.expand_path('../../../monit.cfg.erb', __FILE__))
    end

    def context
      OpenStruct.new({ :pwd => File.expand_path('../../..', __FILE__) })
    end

    def generated_config_path
      File.expand_path('../../../monit.cfg', __FILE__)
    end
  end
end
