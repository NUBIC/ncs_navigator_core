# -*- coding: utf-8 -*-

module NcsNavigator
  module Core
    autoload :Fieldwork,                'ncs_navigator/core/fieldwork'
    autoload :MdesCodeListLoader,       'ncs_navigator/core/mdes_code_list_loader'
    autoload :MdesInstrumentSurvey,     'ncs_navigator/core/mdes_instrument_survey'
    autoload :Mustache,                 'ncs_navigator/core/mustache'
    autoload :Pbs,                      'ncs_navigator/core/pbs'
    autoload :Psc,                      'ncs_navigator/core/psc'
    autoload :RecordOfContactImporter,  'ncs_navigator/core/record_of_contact_importer'
    autoload :RedisConfiguration,       'ncs_navigator/core/redis_configuration'
    autoload :Warehouse,                'ncs_navigator/core/warehouse'
  end
end
