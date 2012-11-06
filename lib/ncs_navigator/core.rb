# -*- coding: utf-8 -*-

module NcsNavigator
  module Core
    autoload :VERSION,                  'ncs_navigator/core/version'

    autoload :Configuration,            'ncs_navigator/core/configuration'
    autoload :Field,                    'ncs_navigator/core/field'
    autoload :HasPublicId,              'ncs_navigator/core/has_public_id'
    autoload :Mdes,                     'ncs_navigator/core/mdes'
    autoload :MdesCodeListLoader,       'ncs_navigator/core/mdes_code_list_loader'
    autoload :MdesInstrumentSurvey,     'ncs_navigator/core/mdes_instrument_survey'
    autoload :Mustache,                 'ncs_navigator/core/mustache'
    autoload :Pbs,                      'ncs_navigator/core/pbs'
    autoload :Psc,                      'ncs_navigator/core/psc'
    autoload :RecordOfContactImporter,  'ncs_navigator/core/record_of_contact_importer'
    autoload :Surveyor,                 'ncs_navigator/core/surveyor'
    autoload :RedisConfiguration,       'ncs_navigator/core/redis_configuration'
    autoload :Warehouse,                'ncs_navigator/core/warehouse'
    autoload :ResponseSetPopulator,     'ncs_navigator/core/response_set_populator'
  end
end
