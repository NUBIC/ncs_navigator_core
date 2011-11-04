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

    def self.code(i)
      Factory(:ncs_code, :local_code => i)
    end

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

      context 'with manually determined variables' do
        before do
          # ignore unused so we can see the mapping failures
          NavigatorCore.on_unused_columns :ignore
        end

        after do
          NavigatorCore.on_unused_columns :fail
        end

        [
          [:marital_status,                 code(9),     :maristat,     '9'],
          [:marital_status_other,           'On fire',   :maristat_oth],
          [:language,                       code(4),     :person_lang,  '4'],
          [:language_other,                 'Esperanto', :person_lang_oth],
          [:preferred_contact_method,       code(1),     :pref_contact, '1'],
          [:preferred_contact_method_other, 'Pigeon',    :pref_contact_oth],
          [:planned_move,                   code(4),     :plan_move,    '4'],
        ].each do |core_field, core_value, wh_field, wh_value|
          it "maps #{core_field} to #{wh_field}" do
            wh_value ||= core_value
            Person.last.tap { |p| p.send("#{core_field}=", core_value) }.save!
            results.last.send(wh_field).should == wh_value
          end
        end
      end
    end
  end
end
