# Models need to all be loaded for NcsCode.attribute_lookup to work. They are
# eagerly loaded by Rails in staging/production/test, but not development.
unless Rails.configuration.cache_classes
  Rails.logger.debug "Eager-loading models for development"
  Dir[(Rails.root + 'app/models/**/*.rb').to_s].each do |model_file|
    require_dependency model_file
  end
end
