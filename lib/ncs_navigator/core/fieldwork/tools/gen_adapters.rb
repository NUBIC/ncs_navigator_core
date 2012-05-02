#!/usr/bin/env ruby

# Generates adapter classes from the fieldwork schema.
#
# Recommended invocation:
#
# ./gen_adapters.rb | git stripspace
require 'active_support/inflector'
require 'erb'
require 'json'
require 'yaml'

def properties_for(schema)
  schema.reject { |k, v| v['items'] }.map(&:first).sort
end

root = File.expand_path('../../../../../..', __FILE__)
schema_file = File.expand_path('vendor/ncs_navigator_schema/fieldwork_schema.json', root)

schema = JSON.parse(File.read(schema_file))
rev = Dir.chdir(File.dirname(schema_file)) { `git show --format=oneline HEAD | head -n1 | cut -c1-40` }.chomp

@contact_properties = properties_for(schema['properties']['contacts']['items']['properties'])
@event_properties = properties_for(schema['properties']['contacts']['items']['properties']['events']['items']['properties'])
@person_properties = properties_for(schema['properties']['participants']['items']['properties']['persons']['items']['properties'])
@instrument_properties = properties_for(schema['properties']['contacts']['items']['properties']['events']['items']['properties']['instruments']['items']['properties'])

schema_file = File.expand_path('vendor/ncs_navigator_schema/response_set_schema.json', root)
schema = JSON.parse(File.read(schema_file))

@response_set_properties = properties_for(schema['properties'])
@response_properties = properties_for(schema['properties']['responses']['items']['properties'])

def attributes
  { 'Contact' => @contact_properties,
    'Event' => @event_properties,
    'Instrument' => @instrument_properties,
    'ResponseSet' => @response_set_properties,
    'Response' => @response_properties
  }
end

attribute_map = YAML.load(File.read('fieldwork_to_model.yml'))

def classes
  attributes.keys.sort
end

template = ERB.new(File.read('adapters.rb.erb'), nil, '<>')

puts template.result(binding)
