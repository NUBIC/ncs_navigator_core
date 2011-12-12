require 'spec_helper'

require 'ncs_navigator/core/warehouse'

require File.expand_path('../importer_warehouse_setup', __FILE__)

module NcsNavigator::Core::Warehouse
  describe OperationalImporter, :clean_with_truncation do
    MdesModule = NcsNavigator::Warehouse::Models::TwoPointZero

    include_context :importer_spec_warehouse

    let(:importer) {
      OperationalImporter.new(wh_config)
    }

    let(:enumerator) {
      OperationalEnumerator.new(wh_config, :bcdatabase => bcdatabase_config)
    }

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
    end

    describe 'strategy selection' do
      it 'handles most models automatically' do
        OperationalImporter.automatic_producers.size.should == 20
      end

      [
        MdesModule::LinkContact, MdesModule::Event, MdesModule::Instrument
      ].each do |manual|
        it "handles #{manual} manually" do
          OperationalImporter.automatic_producers.collect(&:model).should_not include(manual)
        end
      end
    end

    describe 'automatic conversion' do
      describe 'of an existing record' do
        let!(:core_person) { Factory(:person, :updated_at => Date.new(2010, 1, 1)) }
        let!(:mdes_person) { enumerator.to_a(:people).first.tap { |p| save_wh(p) } }

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
            save_wh(mdes_person)

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
            save_wh(mdes_person)

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
            save_wh(mdes_address)

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
            save_wh(a)
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
          Address, Email, Telephone,
          Contact
        ].each do |core_model|
          describe core_model do
            let(:core_model) { core_model }

            include_context 'basic model import test'
          end
        end

        describe ParticipantConsent do
          include_context 'basic model import test'

          let(:core_model) { ParticipantConsent }
          let(:core_record) {
            Factory(:participant_consent,
              :person_who_consented => consenter, :person_wthdrw_consent => some_guy)
          }
          let(:consenter) { Factory(:person, :first_name => 'Ginger') }
          let(:some_guy) { Factory(:person) }
        end

        describe ParticipantVisitRecord do
          include_context 'basic model import test'

          let(:core_model) { ParticipantVisitRecord }
          let(:visited) { Factory(:person, :first_name => 'Ginger') }
          let(:core_record) { Factory(:participant_visit_record, :rvis_person => visited) }
        end

        describe ParticipantVisitConsent do
          include_context 'basic model import test'

          let(:core_model) { ParticipantVisitConsent }
          let(:consenter) { Factory(:person, :first_name => 'Ginger') }
          let(:core_record) {
            Factory(:participant_visit_consent, :vis_person_who_consented => consenter)
          }
        end
      end
    end

    def create_warehouse_record_via_core(core_model, wh_id, wh_attributes={})
      Factory(core_model.to_s.underscore, core_model.public_id_field => wh_id)
      producer = OperationalEnumerator.record_producers.
        find { |rp| rp.name == core_model.table_name.to_sym }
      enumerator.each(producer.name) do |mdes_rec|
        if mdes_rec.key.first == wh_id
          mdes_rec.attributes = wh_attributes
          save_wh(mdes_rec)
        end
      end
      core_model.delete_all(["#{core_model.public_id_field} = ?", wh_id])
      producer.model.first(producer.model.key.first.name => wh_id)
    end

    def code_for_event_type(event_type_name)
      code = NcsNavigatorCore.mdes.types.
        find { |type| type.name == 'event_type_cl1' }.code_list.
        find { |cle| cle.label == event_type_name }.value
      NcsCode.find_or_create_by_local_code_and_list_name(
        code, 'EVENT_TYPE_CL1', :display_text => event_type_name)
      code
    end

    describe 'Event, LinkContact, and Instrument' do
      before do
        Event.count.should == 0
      end

      let(:fred_p) {
        create_warehouse_record_via_core(Participant, 'fred_p')
      }
      let(:ginger_p) {
        create_warehouse_record_via_core(Participant, 'ginger_p')
      }

      let(:f_e2) {
        create_warehouse_record_via_core(Event, 'f_e2',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Pregnancy Screener'),
          :event_start_date => '2010-09-03')
      }
      let!(:f_e2_i) {
        create_warehouse_record_via_core(Instrument, 'f_e2_i',
          :event => f_e2)
      }
      let(:f_e3) {
        create_warehouse_record_via_core(Event, 'f_e3',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Informed Consent'),
          :event_start_date => '2010-09-03')
      }
      let(:f_e1) {
        create_warehouse_record_via_core(Event, 'f_e1',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Low Intensity Data Collection'),
          :event_start_date => '9666-96-96')
      }
      let(:f_c1) {
        create_warehouse_record_via_core(Contact, 'f_c1', :contact_date => '2010-09-03')
      }
      let!(:f_c1_e1) {
        create_warehouse_record_via_core(ContactLink, 'f_c1_e1',
          :contact => f_c1, :event => f_e1)
      }
      let!(:f_c1_e2) {
        create_warehouse_record_via_core(ContactLink, 'f_c1_e2',
          :contact => f_c1, :event => f_e2)
      }
      let!(:f_c1_e3) {
        create_warehouse_record_via_core(ContactLink, 'f_c1_e3',
          :contact => f_c1, :event => f_e3)
      }
      let(:f_c2) {
        create_warehouse_record_via_core(Contact, 'f_c2', :contact_date => '2010-09-17')
      }
      let!(:f_c2_e3) {
        create_warehouse_record_via_core(ContactLink, 'f_c2_e3', :contact => f_c2, :event => f_e3)
      }

      let(:f_e4) {
        create_warehouse_record_via_core(Event, 'f_e4',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Pregnancy Probability'),
          :event_start_date => '2011-03-09')
      }
      let(:f_c3) {
        create_warehouse_record_via_core(Contact, 'f_c3', :contact_date => '2011-03-08')
      }
      let!(:f_c3_e4) {
        create_warehouse_record_via_core(ContactLink, 'f_c3_e4', :contact => f_c3, :event => f_e4)
      }

      let!(:g_e1) {
        create_warehouse_record_via_core(Event, 'g_e1',
          :participant => ginger_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Pregnancy Screener'),
          :event_start_date => '2010-11-07')
      }
      let!(:g_e1_i) {
        create_warehouse_record_via_core(Instrument, 'g_e1_i',
          :event => g_e1)
      }

      describe 'events without participants' do
        let(:g_c1) {
          create_warehouse_record_via_core(Contact, 'g_c1', :contact_date => '2010-09-17')
        }
        let!(:g_c1_e1) {
          create_warehouse_record_via_core(ContactLink, 'g_c1_e1', :contact => g_c1, :event => g_e1)
        }

        before do
          g_e1.participant = nil
          g_e1.save or fail('Could not update event')

          importer.import
        end

        it 'creates core events' do
          Event.find_by_event_id('g_e1').should_not be_nil
        end

        it 'creates core contact links' do
          ContactLink.find_by_contact_link_id('g_c1_e1').should_not be_nil
        end

        it 'creates core instruments' do
          Instrument.find_by_instrument_id('g_e1_i').should_not be_nil
        end
      end

      describe 'unorderable events without contacts' do
        before do
          g_e1.event_start_date = '9666-96-96'
          g_e1.event_end_date = '9777-97-97'

          save_wh(g_e1)
        end

        it 'creates core events' do
          importer.import
          Event.find_by_event_id('g_e1').should_not be_nil
        end

        it 'creates core instruments' do
          importer.import
          Instrument.find_by_instrument_id('g_e1_i').should_not be_nil
        end
      end

      describe 'unorderable contacts' do
        let(:g_c1) {
          create_warehouse_record_via_core(Contact, 'g_c1', :contact_date => '9777-97-97')
        }
        let!(:g_c1_e1) {
          create_warehouse_record_via_core(ContactLink, 'g_c1_e1', :contact => g_c1, :event => g_e1)
        }

        before do
          g_e1.event_start_date = '9666-96-96'
          g_e1.event_end_date = '9666-96-96'

          save_wh(g_e1)

          importer.import
        end

        it 'creates core contact links' do
          ContactLink.find_by_contact_link_id('g_c1_e1').should_not be_nil
        end

        it 'creates core events' do
          Event.find_by_event_id('g_e1').should_not be_nil
        end

        it 'creates core instruments' do
          Instrument.find_by_instrument_id('g_e1_i').should_not be_nil
        end
      end

      describe 'orderable, participant-associated instances' do
        describe 'order' do
          let(:order) { importer.ordered_event_sets }

          def events_for(which)
            order.to_a.detect { |p_id, events_and_links| p_id == which }.
              last.collect { |event_and_links| event_and_links[:event] }
          end

          it 'is an enumerable' do
            order.should be_a(Enumerable)
          end

          it 'is segmented by participant' do
            order.collect { |p_id, links| p_id }.sort.should == %w(fred_p ginger_p)
          end

          # TODO: this is a way crappy test
          it 'orders by the contact date followed by the event start date followed by the event end date followed by the type' do
            events_for('fred_p').collect(&:event_id).should == %w(f_e2 f_e3 f_e1 f_e4)
          end

          it 'includes events without link_contact' do
            events_for('ginger_p').first.event_id.should == 'g_e1'
          end
        end

        describe 'produced participant status history' do
          let(:participant) { Participant.find_by_p_id('fred_p') }

          let(:target_states) {
            participant.low_intensity_state_transition_audits.order(:id).collect(&:to)
          }

          let(:expected_states) {
            %w(pending registered in_pregnancy_probability_group consented_low_intensity following_low_intensity)
          }

          before do
            importer.import
          end

          it 'is in the correct order' do
            target_states.should == expected_states
          end

          it 'does not duplicate already-imported events' do
            importer.import # twice
            target_states.should == expected_states
          end
        end

        it 'saves the events' do
          importer.import
          Event.joins(:participant).where('participants.p_id' => 'fred_p').
            collect(&:event_id).sort.should == %w(f_e1 f_e2 f_e3 f_e4)
        end

        it 'saves the contact_links' do
          importer.import
          ContactLink.all.collect(&:contact_link_id).sort.should ==
            MdesModule::LinkContact.all.collect(&:contact_link_id).sort
        end

        it 'saves the instruments' do
          importer.import
          MdesModule::Instrument.all.collect(&:instrument_id).sort.should == %w(f_e2_i g_e1_i)
        end
      end
    end
  end
end
