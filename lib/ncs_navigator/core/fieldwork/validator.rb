# -*- coding: utf-8 -*-


require 'json-schema'
require 'ncs_navigator/core'
require 'uri'

module NcsNavigator::Core::Fieldwork
  ##
  # A JSON::Validator facade for fieldwork JSON that sets up links to
  # referenced schemata.
  #
  # This isn't thread-safe because Validator isn't thread-safe:
  # JSON::Validator.add_schema modifies class-level state without
  # synchronization.  Also see
  # https://github.com/hoxworth/json-schema/issues/24.
  #
  # As such, you'll need to synchronize accesses to Validator#validate.
  class Validator
    BASE_URI = "http://download.nubic.northwestern.edu/ncs_navigator/"

    SCHEMA_ROOT = "#{Rails.root}/vendor/ncs_navigator_schema"

    def with_referenced_schemata
      begin
        Dir["#{SCHEMA_ROOT}/*.json"].each do |fn|
          basename = File.basename(fn)
          json = JSON.parse(File.read(fn))
          uri = URI.join(BASE_URI, basename)
          schema = JSON::Schema.new(json, uri)

          JSON::Validator.add_schema(schema)
        end

        yield

      ensure
        JSON::Validator.clear_cache
      end
    end

    def fully_validate(data)
      root_schema = JSON.parse(File.read("#{SCHEMA_ROOT}/fieldwork_schema.json"))

      JSON::Validator.fully_validate(root_schema, data)
    end
  end
end