require 'spec_helper'

require 'ncs_navigator/warehouse/transformers/navigator_core'

module NcsNavigator::Warehouse::Transformers
  describe NavigatorCore, :clean_with_truncation, :slow do
    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = File.join(Rails.root, 'log/wh.log')
        config.set_up_logs
        config.output_level = :quiet
      end
    }

    it 'can be created' do
      NavigatorCore.create_transformer(wh_config).should_not be_nil
    end

    it 'uses the correct bcdatabase config' do
      NavigatorCore.bcdatabase[:name].should == 'ncs_navigator_core'
    end

    let(:bcdatabase_config) {
      if Rails.env == 'ci'
        { :group => 'public_ci_postgresql9' }
      else
        { :name => 'ncs_navigator_core_test' }
      end
    }
    let(:enumerator) {
      NavigatorCore.new(wh_config, :bcdatabase => bcdatabase_config)
    }
    let(:producer_names) { [] }
    let(:results) { enumerator.to_a(*producer_names) }

    describe 'for Person' do
      before do
        Factory(:person)
        Factory(:person, :first_name => 'Ginger')

        producer_names << :people
      end

      it 'creates one Person per core Person' do
        results.size.should == 2
      end

      it 'creates Persons with the correct first_names' do
        results.collect(&:first_name).should == %w(Fred Ginger)
      end
    end
  end
end
