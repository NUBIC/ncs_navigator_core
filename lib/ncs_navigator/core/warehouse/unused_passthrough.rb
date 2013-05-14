# -*- coding: utf-8 -*-

require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  module UnusedPassthrough
    OPS_TABLES = %w(
      staff staff_language staff_cert_training staff_weekly_expense
      staff_exp_mngmnt_tasks staff_exp_data_cllctn_tasks outreach
      outreach_lang2 outreach_race outreach_target outreach_eval
      outreach_staff
    )

    def initialize(wh_config)
      @wh_config = wh_config
    end

    def import
      path.parent.mkpath
      create_emitter.emit_xml
    end

    def contents
      @contents ||= NcsNavigator::Warehouse::Contents.new(@wh_config, :tables => unused_tables)
    end

    def create_emitter
      @emitter ||= NcsNavigator::Warehouse::XmlEmitter.new(
        @wh_config, path,
        :zip => false, :'include-pii' => true, :content => contents)
    end

    def path
      @path ||= Rails.root + "importer_passthrough/#{filename}-#{timestamp}.xml"
    end

    protected

    def timestamp
      Time.now.getutc.iso8601.gsub(/[^\d]/, '')
    end
  end
end
