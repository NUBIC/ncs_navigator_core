require 'spec_helper'

require 'ncs_navigator/core/warehouse'

module NcsNavigator::Core::Warehouse
  describe Importer, :clean_with_truncation do
    MdesModule = NcsNavigator::Warehouse::Models::TwoPointZero

    before(:all) do
      wh_init.set_up_repository(:both)
      wh_init.replace_schema
      DatabaseCleaner[:data_mapper].strategy = :transaction
    end

    # This is not a `let` due to https://github.com/rspec/rspec-core/issues/500
    def wh_config
      @wh_config ||= NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = File.join(Rails.root, 'log/wh-import_test.log')
        config.set_up_logs
        config.output_level = :quiet
        if bcdatabase_config[:group]
          config.bcdatabase_group = bcdatabase_config[:group]
        end
        config.bcdatabase_entries.merge!(
          # these are deliberately the same since replace_schema only
          # works on the working database, while the importer runs
          # against the reporting database.
          :working   => :ncs_navigator_core_test_mdes_warehouse,
          :reporting => :ncs_navigator_core_test_mdes_warehouse
        )
      end
    end

    # This is not a `let` due to https://github.com/rspec/rspec-core/issues/500
    def wh_init
      @wh_init ||= NcsNavigator::Warehouse::DatabaseInitializer.new(wh_config)
    end

    # This is not a `let` due to https://github.com/rspec/rspec-core/issues/500
    def bcdatabase_config
      @bcdatabase_config ||= if Rails.env == 'ci'
        { :group => :public_ci_postgresql9 }
      else
        { :name => :ncs_navigator_core_test }
      end
    end

    let(:importer) {
      Importer.new(wh_config)
    }

    let(:enumerator) {
      Enumerator.new(wh_config, :bcdatabase => bcdatabase_config)
    }

    describe 'strategy selection' do
      it 'handles most models automatically' do
        Importer.automatic_producers.size.should == 19
      end

      [
        MdesModule::LinkContact,
        MdesModule::Contact,
        MdesModule::Event,
        MdesModule::Instrument
      ].each do |manual|
        it "handles #{manual} manually" do
          Importer.automatic_producers.collect(&:model).should_not include(manual)
        end
      end
    end

    describe 'automatic conversion' do
      describe 'of an existing record' do
        let!(:core_person) { Factory(:person, :updated_at => Date.new(2010, 1, 1)) }
        let!(:mdes_person) { enumerator.to_a(:people).first.tap { |p| p.save } }

        describe 'when it is identical' do
          before do
            importer.import(:people)
          end

          it 'does nothing to the existing record' do
            Person.first.updated_at.to_date.should == Date.new(2010, 1, 1)
          end

          it 'does not add a new record' do
            Person.count.should == 1
          end
        end

        describe 'when a scalar field is updated' do
          before do
            mdes_person.last_name = 'Astaire'
            mdes_person.save

            importer.import(:people)
          end

          it 'updates that scalar field in core' do
            Person.first.last_name.should == 'Astaire'
          end

          it 'does not add a new record' do
            Person.count.should == 1
          end
        end

        describe 'when a code field is updated' do
          let!(:new_coded_value) {
            Factory(:ncs_code, :local_code => 4, :list_name => 'MARITAL_STATUS_CL1')
          }

          before do
            mdes_person.maristat = new_coded_value.local_code.to_s
            mdes_person.save

            importer.import(:people)
          end

          it 'updates the association to the code' do
            Person.first.marital_status.should == new_coded_value
          end

          it 'does not add a new record' do
            Person.count.should == 1
          end
        end

        describe 'when an entity association is changed' do
          let!(:core_address) { Factory(:address, :person => core_person) }
          let!(:mdes_address) { enumerator.to_a(:addresses).first.tap { |a| a.save } }

          before do
            second_person = Factory(:person, :last_name => 'MacMurray')
            mdes_address.person_id = second_person.public_id
            mdes_address.save

            importer.import(:addresses)
          end

          it 'updates the association to the core object' do
            Address.first.person.last_name.should == 'MacMurray'
            Address.first.person.id.should_not == core_person.id
          end

          it 'does not add a new record' do
            Address.count.should == 1
          end
        end
      end

      describe 'of a completely new record' do
        let!(:core_person) { Factory(:person) }

        let!(:mdes_address) {
          Factory(:address, :person => core_person, :address_one => '123 Anymain Dr.')
          enumerator.to_a(:addresses).first.tap do |a|
            a.save
            # remove the corresponding core record
            Address.destroy_all
            Address.count.should == 0
          end
        }

        before do
          importer.import(:addresses)
        end

        it 'creates a new record' do
          Address.count.should == 1
        end

        it 'creates a new record with appropriate scalar values' do
          Address.first.address_one.should == '123 Anymain Dr.'
        end

        it 'creates a new record with correct entity associations' do
          Address.first.person.id.should == core_person.id
        end

        it 'creates a new record with correct code associations' do
          Address.first.state.local_code.should == 23
        end
      end

      describe 'when the MDES data creates an invalid Core record' do
        it 'logs the error'

        it 'skips saving the core record'
      end

      shared_context 'basic model import test' do
        let(:core_record) { Factory(core_model.to_s.underscore) }
        let(:core_table) { core_model.table_name.to_sym }

        let!(:mdes_record) {
          core_record # ensure created
          enumerator.to_a(core_table).first.tap do |a|
            a.save || fail("Save of #{a.inspect} failed: #{a.errors.values.join(', ')}")
            # remove the corresponding core record
            core_model.destroy_all
            core_model.count.should == 0
          end
        }

        it 'works' do
          importer.import(core_table)
          core_model.count.should == 1
        end
      end

      describe 'of core model' do
        # with no special data needs
        [
          ListingUnit, DwellingUnit, DwellingHouseholdLink, HouseholdUnit, HouseholdPersonLink,
          Person, PersonRace, ParticipantPersonLink,
          Participant, ParticipantConsentSample,
          # participant authorization form requires a provider in the MDES
          # ParticipantAuthorizationForm,
          PpgDetail, PpgStatusHistory,
          Address, Email, Telephone
        ].each do |core_model|
          describe core_model do
            let(:core_model) { core_model }

            include_context 'basic model import test'
          end
        end

        describe ParticipantConsent do
          let(:core_model) { ParticipantConsent }
          let(:core_record) {
            Factory(:participant_consent,
              :person_who_consented => consenter, :person_wthdrw_consent => some_guy)
          }
          let(:consenter) { Factory(:person, :first_name => 'Ginger') }
          let(:some_guy) { Factory(:person) }

          include_context 'basic model import test'
        end

        describe ParticipantVisitRecord do
          let(:core_model) { ParticipantVisitRecord }
          let(:visited) { Factory(:person, :first_name => 'Ginger') }
          let(:core_record) { Factory(:participant_visit_record, :rvis_person => visited) }

          include_context 'basic model import test'
        end

        describe ParticipantVisitConsent do
          let(:core_model) { ParticipantVisitConsent }
          let(:consenter) { Factory(:person, :first_name => 'Ginger') }
          let(:core_record) {
            Factory(:participant_visit_consent, :vis_person_who_consented => consenter)
          }

          include_context 'basic model import test'
        end
      end
    end

    describe 'special conversions' do
      describe 'for Participant' do
        it 'creates the direct link between participant and person'
      end

      describe 'for ContactLink, Contact, Event, Instrument' do
        it 'works, etc.'
      end
    end
  end
end
