namespace :configuration do

  task :copy_image_files => :environment do 
    require 'ncs_navigator/configuration'
    ["left", "right"].each do |i|
      from = NcsNavigator.configuration.send("footer_logo_#{i}").to_s
      to = "#{Rails.root}/public/images/#{from.split("/").last}"
      `cp #{from} #{to}`
    end
  end

end
