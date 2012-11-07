# -*- coding: utf-8 -*-

require 'json-schema'
require 'ncs_navigator/core'
require 'thread'
require 'uri'

module NcsNavigator::Core::Field
  ##
  # A JSON::Validator facade for fieldwork JSON that sets up links to
  # referenced schemata.
  class Validator
    BASE_URI = "http://download.nubic.northwestern.edu/ncs_navigator/"

    ##
    # Where the schema definitions are stored.
    SCHEMA_ROOT = "#{Rails.root}/vendor/ncs_navigator_schema"

    ##
    # The validator's primary use is validating fieldwork data, which makes
    # this a convenient default.  However, there's no reason why other schemas
    # can't be used.
    FIELDWORK_SCHEMA = JSON.parse(File.read("#{SCHEMA_ROOT}/fieldwork_schema.json")).freeze

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
    def fully_validate(data, root_schema = FIELDWORK_SCHEMA)
      LOCK.synchronize do
        with_referenced_schemas do
          JSON::Validator.fully_validate(root_schema, data)
        end
      end
    end

    ##
    # Expands all references in the fieldwork schema.  Used in the merge tests.
    def expanded_schema(root_schema = FIELDWORK_SCHEMA.dup)
      LOCK.synchronize do
        with_referenced_schemas do
          schemas = JSON::Validator.schemas.dup

          rewrite = lambda do |schema|
            if Hash === schema
              schema.each do |k, v|
                if Hash === v
                  if v['$ref']
                    schema.update(k => rewrite[schemas[v['$ref']].schema])
                  end

                  if v['extends'] && v['extends']['$ref']
                    ref = v['extends']['$ref']
                    v.delete('extends')
                    orig = v.dup

                    v.deep_merge!(rewrite[schemas[ref]].schema)
                  end
                end

                rewrite[v]
              end
            end

            schema
          end

          rewrite[root_schema]
        end
      end
    end

    ##
    # @private
    def with_referenced_schemas
      begin
        json = JSON.parse(File.read("#{SCHEMA_ROOT}/refs.json"))

        json['refs'].each do |schema|
          uri = schema['$ref']
          full_path = "#{SCHEMA_ROOT}/#{schema['fn']}"
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
