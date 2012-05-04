# -*- coding: utf-8 -*-

require 'json-schema'
require 'ncs_navigator/core'
require 'thread'
require 'uri'

module NcsNavigator::Core::Fieldwork
  ##
  # A JSON::Validator facade for fieldwork JSON that sets up links to
  # referenced schemata.
  class Validator
    BASE_URI = "http://download.nubic.northwestern.edu/ncs_navigator/"

    ##
    # Where the schema definitions are stored.
    SCHEMA_ROOT = "#{Rails.root}/vendor/ncs_navigator_schema"

    ##
    # For JSON::Validator.
    #
    # @see https://github.com/hoxworth/json-schema/issues/24
    LOCK = Mutex.new

    ##
    # Report all validation errors in a fieldwork document.
    #
    # Implementation note: Yes, this method does in fact re-read schema
    # information from the filesystem for each call.  JSON::Validator#validate
    # -- an _instance_ method -- resets referenced schema data, which is
    # stored at _class_ level.  (Sigh.)
    def fully_validate(data)
      LOCK.synchronize do
        with_referenced_schemas do
          root_schema = JSON.parse(File.read("#{SCHEMA_ROOT}/fieldwork_schema.json"))

          JSON::Validator.fully_validate(root_schema, data)
        end
      end
    end

    ##
    # @private
    def with_referenced_schemas
      begin
        JSON.parse(File.read("#{SCHEMA_ROOT}/refs.json")).each do |uri, fn|
          full_path = "#{SCHEMA_ROOT}/#{fn}"
          schema = JSON::Schema.new(JSON.parse(File.read(full_path)), URI.parse(uri))

          JSON::Validator.add_schema(schema)
        end

        yield
      ensure
        JSON::Validator.clear_cache
      end
    end
  end
end
