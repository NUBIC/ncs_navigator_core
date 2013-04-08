# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe ArchivalStaffAndOutreachPassthrough, :warehouse do
    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = File.join(Rails.root, 'log/wh.log')
        config.set_up_logs
        config.output_level = :quiet
      end
    }

    let(:passthrough) { ArchivalStaffAndOutreachPassthrough.new(wh_config) }

    describe '#create_emitter', :slow do
      let(:emitter) { passthrough.create_emitter }

      let(:model_tables) { emitter.models.collect(&:mdes_table_name) }

      it 'includes PII' do
        emitter.include_pii?.should be_true
      end

      it 'skips the ZIP' do
        emitter.zip?.should be_false
      end

      it 'writes to a file in the importer_passthrough directory' do
        emitter.filename.to_s.should =~
          %r(#{Rails.root}/importer_passthrough/archived_staff_and_outreach-\d{14}.xml)
      end

      %w(
        staff staff_language staff_cert_training staff_weekly_expense
        staff_exp_mngmnt_tasks staff_exp_data_cllctn_tasks outreach
        outreach_lang2 outreach_race outreach_target outreach_eval
        outreach_staff
      ).each do |table|
        it "includes #{table} since it is handled by Ops" do
          model_tables.should include(table)
        end
      end
    end

    describe '#import' do
      let(:mock_emitter) { mock(NcsNavigator::Warehouse::XmlEmitter) }

      it 'emits the XML' do
        passthrough.should_receive(:create_emitter).and_return(mock_emitter)
        mock_emitter.should_receive(:emit_xml)

        passthrough.import
      end
    end
  end
end
