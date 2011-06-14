desc "Add schema information (as comments) to model files"

task :annotate_models do
   require "#{Rails.root}/vendor/plugins/annotate_models/lib/annotate_models.rb"
   AnnotateModels.do_annotations
end