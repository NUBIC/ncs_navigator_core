namespace :configuration do
  task :copy_image_files => :environment do
    require 'ncs_navigator/configuration'
    ["left", "right"].each do |i|
      from = NcsNavigator.configuration.send("footer_logo_#{i}")
      if from
        to = Rails.root + 'public/assets/images' + from.basename
        cp from, to
      end
    end
  end
end
