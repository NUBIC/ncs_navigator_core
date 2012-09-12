# -*- coding: utf-8 -*-

require 'spec_helper'

require File.expand_path('../importer_warehouse_setup', __FILE__)

module NcsNavigator::Core::Warehouse
  describe LegacyInstrumentImporter, :clean_with_truncation, :slow, :warehouse do
    include_context :importer_spec_warehouse

    let(:importer) { LegacyInstrumentImporter.new(wh_config) }

    let(:core_instrument) { Factory(:instrument) }

    let(:wh_instrument) {
      create_warehouse_record_with_defaults(:Instrument,
        :instrument_id => core_instrument.public_id, :event_id => wh_event.event_id)
    }
    let(:wh_event) {
      create_warehouse_record_with_defaults(:event, :event_start_date => '2010-01-01')
    }

    let(:wh_mother) { create_warehouse_record_with_defaults(:participant, :p_id => 'M') }
    let(:wh_child1) { create_warehouse_record_with_defaults(:participant, :p_id => 'C1') }
    let(:wh_child2) { create_warehouse_record_with_defaults(:participant, :p_id => 'C2') }

    def save_wh(record)
      unless record.save
        messages = record.errors.keys.collect { |prop|
          record.errors[prop].collect { |e|
            v = record.send(prop)
            "#{e} (#{prop}=#{v.inspect})."
          }
        }.flatten
        fail "Could not save #{record} due to validation failures: #{messages.join(', ')}"
      end
      record
    end

    def create_warehouse_record_with_defaults(mdes_model, attributes={})
      mdes_model =
        case mdes_model
        when Class
          mdes_model
        else
          wh_config.model(mdes_model)
        end

      all_attrs = all_missing_attributes(mdes_model).
        merge(attributes)

      save_wh(mdes_model.new(all_attrs))
    end

    describe '#import' do
      let!(:root1) {
        create_warehouse_record_with_defaults(:eighteen_mth_mother,
          :eighteen_mth_mother_id => '18MM_0',
          :instrument => wh_instrument, :p => wh_mother)
      }
      let!(:habit1) {
        create_warehouse_record_with_defaults(:eighteen_mth_mother_habits,
          :eighteen_mth_mother_habits_id => '18MM_0_h1',
          :eighteen_mth_mother => root1, :p => wh_child1)
      }
      let!(:cond1_1) {
        create_warehouse_record_with_defaults(:eighteen_mth_mother_cond,
          :eighteen_mth_mother_cond_id => '18MM_0_h1_c1', :cond => '1',
          :eighteen_mth_habits => habit1)
      }
      let!(:cond1_2) {
        create_warehouse_record_with_defaults(:eighteen_mth_mother_cond,
          :eighteen_mth_mother_cond_id => '18MM_0_h1_c2', :cond => '3',
          :eighteen_mth_habits => habit1)
      }

      let!(:habit2) {
        create_warehouse_record_with_defaults(:eighteen_mth_mother_habits,
          :eighteen_mth_mother_habits_id => '18MM_0_h2',
          :eighteen_mth_mother => root1, :p => wh_child2)
      }

      def legacy_rec_for(wh_record)
        LegacyInstrumentDataRecord.where('mdes_table_name = ? AND public_id = ?',
          wh_record.class.mdes_table_name, wh_record.key.first).first
      end

      describe 'when creating' do
        before do
          importer.import
        end

        it 'creates one legacy record per instrument table row' do
          LegacyInstrumentDataRecord.count.should == 5
        end

        it 'does not create legacy records for operational records' do
          LegacyInstrumentDataRecord.all.collect(&:mdes_table_name).uniq.sort.
            should == %w(eighteen_mth_mother eighteen_mth_mother_cond eighteen_mth_mother_habits)
        end

        it 'links each legacy record to the corresponding cases instrument op record' do
          LegacyInstrumentDataRecord.all.collect(&:instrument).uniq.should == [core_instrument]
        end

        it 'fails if an instrument table references an unknown instrument op record'

        it 'sets the public ID for each legacy record' do
          LegacyInstrumentDataRecord.where(:mdes_table_name => 'eighteen_mth_mother_habits').
            collect(&:public_id).sort.should == %w(18MM_0_h1 18MM_0_h2)
        end

        it 'sets the PSU for each legacy record' do
          LegacyInstrumentDataRecord.all.collect(&:psu_id).uniq.should == [20000030]
        end

        it 'sets the mdes version for each legacy record' do
          LegacyInstrumentDataRecord.all.collect(&:mdes_version).uniq.should == %w(2.0)
        end

        it 'associates a child legacy record with its parent' do
          LegacyInstrumentDataRecord.where('parent_record_id IS NOT NULL').inject({}) { |map, rec|
            map[rec.public_id] = rec.parent_record.public_id; map
          }.should == {
            '18MM_0_h1' => '18MM_0',
            '18MM_0_h2' => '18MM_0',
            '18MM_0_h1_c1' => '18MM_0_h1',
            '18MM_0_h1_c2' => '18MM_0_h1'
          }
        end

        it 'stores operational metadata as legacy values' do
          legacy_rec_for(habit1).values.select { |v| v.mdes_variable_name == 'p_id' }.collect(&:value).
            should == [wh_child1.p_id]
        end

        it 'stores instrument variable values as legacy values' do
          legacy_rec_for(cond1_2).values.select { |v| v.mdes_variable_name == 'cond' }.collect(&:value).
            should == ['3']
        end

        it 'does not store serialized references as values' do
          legacy_rec_for(habit1).values.select { |v| v.mdes_variable_name == 'eighteen_mth_mother' }.
            should be_empty
        end
      end

      describe 'when updating' do
        describe 'a legacy record' do
          let!(:existing_legacy_record) {
            LegacyInstrumentDataRecord.create!(
              :mdes_table_name => habit2.class.mdes_table_name,
              :public_id => habit2.key.first,
              :instrument => core_instrument,
              :mdes_version => '1.8')
          }

          before do
            importer.import
          end

          it 'does not create a new record' do
            LegacyInstrumentDataRecord.count.should == 5
          end

          it 'updates the existing record' do
            existing_legacy_record.reload.mdes_version.should == '2.0'
          end
        end

        describe 'a legacy value' do
          let!(:existing_legacy_record) {
            LegacyInstrumentDataRecord.create!(
              :mdes_table_name => habit2.class.mdes_table_name,
              :public_id => habit2.key.first,
              :instrument => core_instrument,
              :mdes_version => '1.8')
          }

          before do
            existing_legacy_record.values.create!(
              :mdes_variable_name => 'p_id', :value => 'D12')
            existing_legacy_record.values.create!(
              :mdes_variable_name => 'obstreperousness', :value => '4.6')

            importer.import
          end

          it 'updates a value if there is matching value object with the same variable name' do
            existing_legacy_record.reload.values.select { |v| v.mdes_variable_name == 'p_id' }.
              collect(&:value).should == %w(C2)
          end

          it 'removes a value if there is no attribute matching the existing value' do
            existing_legacy_record.reload.values.
              select { |v| v.mdes_variable_name == 'obstreperousness' }.should == []
          end
        end
      end
    end
  end
end
