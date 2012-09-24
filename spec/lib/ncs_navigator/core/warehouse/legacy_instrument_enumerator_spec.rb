# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe LegacyInstrumentEnumerator, :clean_with_truncation, :slow, :warehouse do
    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap { |c|
        c.output_level = :quiet
        c.log_file = Rails.root + 'log/wh.log'
        c.set_up_logs
      }
    }

    let(:bcdatabase_config) {
      case Rails.env
      when 'ci'
        { :group => 'public_ci_postgresql9' }
      when 'ci_warehouse'
        { :group => 'public_ci_postgresql9', :name => 'ncs_navigator_core_wh' }
      else
        { :name => 'ncs_navigator_core_test' }
      end
    }
    let(:enumerator) {
      LegacyInstrumentEnumerator.new(wh_config, :bcdatabase => bcdatabase_config)
    }

    let(:results) { enumerator.to_a }

    it 'can be created' do
      LegacyInstrumentEnumerator.create_transformer(wh_config).should_not be_nil
    end

    it 'uses the correct bcdatabase config' do
      LegacyInstrumentEnumerator.bcdatabase[:name].should == 'ncs_navigator_core'
    end

    it 'creates one warehouse record per legacy record' do
      Factory(:legacy_instrument_data_record, :mdes_table_name => 'birth_visit', :public_id => 'IMP-01')
      Factory(:legacy_instrument_data_record, :mdes_table_name => 'birth_visit', :public_id => 'IMP-02')

      results.collect { |rec| rec.key.first }.sort.should == %w(IMP-01 IMP-02)
    end

    it 'creates warehouse records according to the legacy record table' do
      Factory(:legacy_instrument_data_record, :mdes_table_name => 'birth_visit', :public_id => 'IMP-01')
      Factory(:legacy_instrument_data_record, :mdes_table_name => 'birth_visit_li', :public_id => 'IMP-01')

      results.collect { |rec| rec.class.name.demodulize }.sort.should == %w(BirthVisit BirthVisitLi)
    end

    describe 'with values' do
      let(:bv1_result) { results.find { |r| r.key.first == 'BV1' } }

      before do
        bv1 = Factory(:legacy_instrument_data_record, :mdes_table_name => 'birth_visit', :public_id => 'BV1')
        Factory(:legacy_instrument_data_value, :legacy_instrument_data_record_id => bv1.to_param,
          :mdes_variable_name => 'event_id', :value => 'the event for BV1')
        Factory(:legacy_instrument_data_value, :legacy_instrument_data_record_id => bv1.to_param,
          :mdes_variable_name => 'live_mom', :value => '2')

        bv2 = Factory(:legacy_instrument_data_record, :mdes_table_name => 'birth_visit', :public_id => 'BV2')
        Factory(:legacy_instrument_data_value, :legacy_instrument_data_record_id => bv2.to_param,
          :mdes_variable_name => 'event_id', :value => 'an event of BV2')
      end

      it 'applies the values to the correct records' do
        results.collect { |r| [r.key.first, r.event_id] }.sort.should == [
          ['BV1', 'the event for BV1'],
          ['BV2', 'an event of BV2']
        ]
      end

      it 'applies all the values for each record' do
        [bv1_result.event_id, bv1_result.live_mom].should == ['the event for BV1', '2']
      end
    end

    it 'processes the legacy records parents-first' do
      parent = Factory(:legacy_instrument_data_record, :mdes_table_name => 'eighteen_mth_mother', :public_id => 'PARENT-01')
      child = Factory(:legacy_instrument_data_record, :mdes_table_name => 'eighteen_mth_mother_habits',
        :public_id => 'CHILD-01', :parent_record_id => parent.to_param)
      grandchild = Factory(:legacy_instrument_data_record, :mdes_table_name => 'eighteen_mth_mother_cond',
        :public_id => 'GCHILD-01', :parent_record_id => child.to_param)
      child2 = Factory(:legacy_instrument_data_record, :mdes_table_name => 'eighteen_mth_mother_habits',
        :public_id => 'CHILD-02', :parent_record_id => parent.to_param)

      # PostgreSQL returns records earliest-last-update-first by default, so this
      # makes the naive query implementation not match the spec.
      child.update_attribute(:public_id, 'CHILD-0!')
      parent.update_attribute(:public_id, 'PARENT-0!')

      results.collect { |rec| rec.class.name.demodulize }.
        should == %w(EighteenMthMother EighteenMthMotherHabits EighteenMthMotherHabits EighteenMthMotherCond)
    end
  end
end
