namespace :monit do
  namespace :config do
    desc 'Generate the monit configuration for Core'
    task :generate do
      puts ERB.new(template).result(binding)
    end

    def template
      File.read(File.expand_path('../monit.cfg.erb', __FILE__))
    end
  end
end
