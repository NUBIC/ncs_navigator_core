# -*- coding: utf-8 -*-

module NcsNavigator
  module Core
    autoload :VERSION,                  'ncs_navigator/core/version'

    autoload :CaseCloner,                 'ncs_navigator/core/case_cloner'
    autoload :Configuration,              'ncs_navigator/core/configuration'
    autoload :Field,                      'ncs_navigator/core/field'
    autoload :FollowedParticipantChecker, 'ncs_navigator/core/followed_participant_checker'
    autoload :HasPublicId,                'ncs_navigator/core/has_public_id'
    autoload :Mdes,                       'ncs_navigator/core/mdes'
    autoload :MdesInstrumentSurvey,       'ncs_navigator/core/mdes_instrument_survey'
    autoload :Mustache,                   'ncs_navigator/core/mustache'
    autoload :Pbs,                        'ncs_navigator/core/pbs'
    autoload :Psc,                        'ncs_navigator/core/psc'
    autoload :RecordOfContactImporter,    'ncs_navigator/core/record_of_contact_importer'
    autoload :RedisConfiguration,         'ncs_navigator/core/redis_configuration'
    autoload :SidekiqConfiguration,       'ncs_navigator/core/sidekiq_configuration'
    autoload :StatusChecks,               'ncs_navigator/core/status_checks'
    autoload :Surveyor,                   'ncs_navigator/core/surveyor'
    autoload :Warehouse,                  'ncs_navigator/core/warehouse'
    autoload :WorkerWatchdog,             'ncs_navigator/core/worker_watchdog'
  end
end
