# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe IneligibleBatchEnumerator, :clean_with_truncation, :slow, :warehouse do
    def get_wh_config(mdes_version = '2.2')
      NcsNavigator::Warehouse::Configuration.new.tap { |c|
        c.output_level = :quiet
        c.log_file = Rails.root + 'log/wh.log'
        c.set_up_logs
        c.mdes_version = mdes_version
      }
    end

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

    let(:results) {
      Factory(:ineligible_batch)
      Factory(:ineligible_batch,
              :people_count => 2)
      enumerator.to_a
    }

    let(:results_i) {
      Factory(:ineligible_batch,
              :pregnancy_eligible_code => 1)
      Factory(:ineligible_batch,
              :people_count => 2,
              :pregnancy_eligible_code => 1)
      enumerator.to_a
    }

    it 'creates an instance of EnumTransformer' do
      IneligibleBatchEnumerator.create_transformer(get_wh_config).should_not be_nil
    end

    it 'uses the correct bcdatabase config' do
      IneligibleBatchEnumerator.bcdatabase[:name].should == 'ncs_navigator_core'
    end

    context "with MDES version 2.0" do
      let(:wh_config) {
        get_wh_config(mdes_version = '2.0')
      }
      let(:enumerator) {
        IneligibleBatchEnumerator.new(wh_config,
                                     :bcdatabase => bcdatabase_config)
      }

      it "creates three MDES v2.0 Person records" do
      results.count.should == 6
        results.select { |r|
          NcsNavigator::Warehouse::Models::TwoPointZero::Person === r
        }.length.should == 3
      end

      it "creahhhes three MDES v2.0 LinkPersonProvider records" do
      results.count.should == 6
        results.select { |r|
          NcsNavigator::Warehouse::Models::TwoPointZero::LinkPersonProvider === r
        }.length.should == 3
      end

      it "initializes all required attributes for all MDES tables" do
        Factory(:ineligible_batch,
                :people_count => 1,
                :pregnancy_eligible_code => 1)

        2.times do |i|
          model = results[i]
          tname = model.class.mdes_table_name

          mandatory = wh_config.mdes.transmission_tables.find { |t|
            t.name == tname
          }.variables.reject(&:nillable).collect(&:name)
          present = model.attributes.keys.map(&:to_s)

          (mandatory & present).should == mandatory
          mandatory.each { |m| model[m].should_not be_nil }
        end

      end

    end

    context "with MDES version 3.0" do
      let(:wh_config) {
        get_wh_config(mdes_version = '3.0')
      }
      let(:enumerator) {
        IneligibleBatchEnumerator.new(wh_config,
                                     :bcdatabase => bcdatabase_config)
      }

      it "creates three MDES v3.0 Person records" do
        results.count.should == 6
        results.select { |r|
          NcsNavigator::Warehouse::Models::ThreePointZero::Person === r
        }.length.should == 3
      end

      it "creates three MDES v3.0 LinkPersonProvider records" do
        results.count.should == 6
        results.select { |r|
          NcsNavigator::Warehouse::Models::ThreePointZero::LinkPersonProvider === r
        }.length.should == 3
      end

      it "doesn't create and MDES v3.0 SampledPersonsIneligibility records if SampledPersonsIneligibility attributes are not present" do
        results.count.should == 6
        results.select { |r|
          NcsNavigator::Warehouse::Models::ThreePointZero::SampledPersonsIneligibility === r
        }.length.should == 0
      end

      it "creates three MDES v3.0 SampledPersonsIneligibility records if SampledPersonsIneligibility attributes are present" do
        results_i.count.should == 9
        results_i.select { |r|
          NcsNavigator::Warehouse::Models::ThreePointZero::SampledPersonsIneligibility === r
        }.length.should == 3
      end

      it "initializes all required attributes for all MDES tables" do
        Factory(:ineligible_batch,
                :people_count => 1,
                :pregnancy_eligible_code => 1)

        3.times do |i|
          model = results[i]
          tname = model.class.mdes_table_name

          mandatory = wh_config.mdes.transmission_tables.find { |t|
            t.name == tname
          }.variables.reject(&:nillable).collect(&:name)
          present = model.attributes.keys.map(&:to_s)

          (mandatory & present).should == mandatory
          mandatory.each { |m| model[m].should_not be_nil }
        end
      end

    end

  end
end
