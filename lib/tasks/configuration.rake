namespace :configuration do
  task :copy_image_files => :environment do
    require 'ncs_navigator/configuration'
    ["left", "right"].each do |i|
      from = NcsNavigator.configuration.send("footer_logo_#{i}")
      if from
        to = Rails.root + 'public/assets' + from.basename
        if to.exist?
          # Ensure that the target is writable if it already exists.
          # This check & update permits the source images to be
          # completely read only but still allow the deployed copies
          # to be overwritten.
          chmod 0664, to.to_s # use FileUtils for the echo
        end
        cp from, to
      end
    end
  end
end
