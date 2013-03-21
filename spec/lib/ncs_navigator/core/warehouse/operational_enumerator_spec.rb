require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe OperationalEnumerator, :warehouse, :slow do
    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = File.join(Rails.root, 'log/wh.log')
        config.set_up_logs
        config.output_level = :quiet
      end
    }

    describe '.create_transformer' do
      let(:actual) { OperationalEnumerator.create_transformer(wh_config, options) }
      let(:options) { {} }

      describe 'for MDES 2.0' do
        before do
          wh_config.mdes_version = '2.0'
        end

        it 'uses the TwoPointZero version' do
          actual.enum.should be_a TwoPointZero::OperationalEnumerator
        end

        it 'passes along the options' do
          options[:duplicates] = :ignore
          actual.duplicates.should == :ignore
        end
      end

      # N.b.: this test is only actually possible if there is a version
      # of the MDES that the Warehouse supports but for which there is no
      # corresponding op enumerator. This is true now but will not always be.
      describe 'for an unsupported MDES version' do
        before do
          pending 'There are no longer any unsupported MDES versions for this test to use.'
          wh_config.mdes_version = '3.1'
        end

        it 'throws an exception' do
          expect { actual }.to raise_error(/^Cases has no operational enumerator for MDES 3.1./)
        end
      end
    end
  end
end
