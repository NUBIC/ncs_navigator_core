require 'json'
require 'jsv'
require 'ncs_navigator/core'

module NcsNavigator::Core::Field
  ##
  # Validates incoming JSON data from Field.
  #
  # Example
  # -------
  #
  #     v = JSONValidator.new
  #     report = v.validate(json_as_str) # => a JSV::Report
  #
  #     report.has_errors?  # => true/false
  #     report.errors       # => error list
  #
  #
  # Thread safety
  # -------------
  #
  # A JSONValidator object should not be shared across threads, but each thread
  # may safely instantiate their own JSONValidators and concurrently validate
  # JSON.
  class JSONValidator
    SCHEMA_SUBMODULE_PATH = Rails.root.join('vendor/ncs_navigator_schema')

    def self.relpath(p)
      File.expand_path(p, SCHEMA_SUBMODULE_PATH)
    end

    FIELDWORK_SCHEMA = relpath('fieldwork_schema.json')

    def initialize(schema_fn = FIELDWORK_SCHEMA)
      verify_schema_submodule_presence!

      @jsv = JSV::Context.new
      @env = @jsv.create_environment('json-schema-draft-03')
      @schema = File.read(schema_fn)
      setup_environment
    end

    ##
    # Validates JSON in string form.
    #
    # @return JSV::Report
    def validate(json)
      @env.validate(json, @schema)
    end

    private

    def setup_environment
      refs = JSON.parse(File.read(relpath('refs.json')))

      refs['refs'].each do |ref|
        schema = File.read(relpath(ref['fn']))

        @env.create_schema(schema, nil, ref['$ref'])
      end
    end

    def relpath(p)
      self.class.relpath(p)
    end

    def verify_schema_submodule_presence!
      unless File.exists?("#{SCHEMA_SUBMODULE_PATH}/.git")
        raise "#{SCHEMA_SUBMODULE_PATH} is empty.  Have submodules been initialized?"
      end
    end
  end
end
