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
        OperationalImporter.automatic_producers.size.should == 25
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

      describe 'resolving associations' do
        let(:auto_names) { OperationalImporter.automatic_producers.collect(&:name) }

        describe 'backward' do
          let!(:mdes_person) { create_warehouse_record_via_core(Person, 'P24') }
          let!(:mdes_link) {
            create_warehouse_record_via_core(ParticipantPersonLink, 'LP42',
              :person => mdes_person)
          }

          before do
            # test setup
            auto_names.index(:people).should < auto_names.index(:participant_person_links)
            importer.import(:people, :participant_person_links)
          end

          it 'works' do
            ParticipantPersonLink.find_by_person_pid_id('LP42').person.should ==
              Person.find_by_person_id('P24')
          end
        end

        describe 'forward' do
          let!(:mdes_contact) { create_warehouse_record_via_core(Contact, 'C5') }
          let!(:mdes_consent) {
            create_warehouse_record_via_core(ParticipantConsent, 'PC3', :contact => mdes_contact)
          }

          before do
            # test setup
            auto_names.index(:participant_consents).should < auto_names.index(:contacts)
            importer.import(:participant_consents, :contacts)
          end

          it 'works' do
            ParticipantConsent.find_by_participant_consent_id('PC3').
              contact.should == Contact.find_by_contact_id('C5')
          end
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
          NonInterviewReport, NoAccessNonInterviewReport, DwellingUnitTypeNonInterviewReport,
          RefusalNonInterviewReport, VacantNonInterviewReport
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

        describe Contact do
          include_context 'basic model import test'
          let(:core_model) { Contact }

          describe '#contact_disposition' do
            describe 'with an interim code' do
              before do
                mdes_record.contact_disp = '78'
                save_wh(mdes_record)
              end

              it 'imports as an interim code' do
                importer.import(core_table)
                core_model.first.contact_disposition.should == 78
              end
            end

            describe 'with a final code' do
              before do
                mdes_record.contact_disp = '558'
                save_wh(mdes_record)
              end

              it 'imports as an interim code' do
                importer.import(core_table)
                core_model.first.contact_disposition.should == 58
              end
            end
          end
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
      core_model.destroy_all(["#{core_model.public_id_field} = ?", wh_id])
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

    def code_for_instrument_type(instrument_type_name)
      code = NcsNavigatorCore.mdes.types.
        find { |type| type.name == 'instrument_type_cl1' }.code_list.
        find { |cle| cle.label == instrument_type_name }.value
      NcsCode.find_or_create_by_local_code_and_list_name(
        code, 'INSTRUMENT_TYPE_CL1', :display_text => instrument_type_name)
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

      let(:fred_pers) {
        create_warehouse_record_via_core(Person, 'fred_pers')
      }
      let(:ginger_pers) {
        create_warehouse_record_via_core(Person, 'ginger_pers')
      }

      let!(:fred_p_pers_link) {
        create_warehouse_record_via_core(ParticipantPersonLink, 'fred_p_pers_link',
          :p => fred_p,
          :person => fred_pers)
      }
      let!(:ginger_p_pers_link) {
        create_warehouse_record_via_core(ParticipantPersonLink, 'ginger_p_pers_link',
          :p => ginger_p,
          :person => ginger_pers)
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
          :instrument_type => code_for_instrument_type('Pregnancy Screener Interview (HI,LI)'),
          :ins_status => 1,
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
          :contact => f_c1, :event => f_e1, :instrument => nil)
      }
      let!(:f_c1_e2) {
        create_warehouse_record_via_core(ContactLink, 'f_c1_e2',
          :contact => f_c1, :event => f_e2, :instrument => f_e2_i)
      }
      let!(:f_c1_e3) {
        create_warehouse_record_via_core(ContactLink, 'f_c1_e3',
          :contact => f_c1, :event => f_e3, :instrument => nil)
      }
      let(:f_c2) {
        create_warehouse_record_via_core(Contact, 'f_c2', :contact_date => '2010-09-17')
      }
      let!(:f_c2_e3) {
        create_warehouse_record_via_core(ContactLink, 'f_c2_e3',
          :contact => f_c2, :event => f_e3, :instrument => nil)
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
        create_warehouse_record_via_core(ContactLink, 'f_c3_e4',
          :contact => f_c3, :event => f_e4, :instrument => nil)
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
          :instrument_type => code_for_instrument_type('Pregnancy Screener Interview (HI,LI)'),
          :event => g_e1)
      }

      def do_import
        importer.import
      end

      describe 'data mapping' do
        describe 'for Event' do
          describe '#event_disposition' do
            describe 'with a final code' do
              before do
                g_e1.event_disp = 522
                save_wh(g_e1)
              end

              it 'imports as an interim code' do
                do_import
                Event.find_by_event_id('g_e1').event_disposition.should == 22
              end
            end

            describe 'with an interim code' do
              before do
                g_e1.event_disp = 45
                save_wh(g_e1)
              end

              it 'imports as an interim code' do
                do_import
                Event.find_by_event_id('g_e1').event_disposition.should == 45
              end
            end
          end
        end
      end

      describe 'events without participants' do
        let(:g_c1) {
          create_warehouse_record_via_core(Contact, 'g_c1', :contact_date => '2010-09-17')
        }
        let!(:g_c1_e1) {
          create_warehouse_record_via_core(ContactLink, 'g_c1_e1',
            :contact => g_c1, :event => g_e1, :instrument => g_e1_i)
        }

        before do
          g_e1.participant = nil
          g_e1.save or fail('Could not update event')

          do_import
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

          do_import
        end

        it 'creates core events' do
          Event.find_by_event_id('g_e1').should_not be_nil
        end

        it 'creates core instruments' do
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

          do_import
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
            %w(pending registered in_pregnancy_probability_group consented_low_intensity following_low_intensity following_low_intensity)
          }

          before do
            do_import
          end

          it 'associates person with participant' do
            person = Person.find_by_person_id('fred_pers')
            person.should_not be_nil
            participant.should_not be_nil
            participant.participant_person_links.should_not be_empty
            participant.participant_person_links.first.person.should == person
            participant.person.should_not be_nil
            participant.person.should == person
          end

          it 'is in the correct order' do
            target_states.should == expected_states
          end

          it 'does not duplicate already-imported events' do
            do_import # twice
            target_states.should == expected_states
          end
        end

        it 'saves the events' do
          do_import
          Event.joins(:participant).where('participants.p_id' => 'fred_p').
            collect(&:event_id).sort.should == %w(f_e1 f_e2 f_e3 f_e4)
        end

        it 'saves the contact_links' do
          do_import
          ContactLink.all.collect(&:contact_link_id).sort.should ==
            MdesModule::LinkContact.all.collect(&:contact_link_id).sort
        end

        it 'saves the instruments' do
          do_import
          MdesModule::Instrument.all.collect(&:instrument_id).sort.should == %w(f_e2_i g_e1_i)
        end

        describe 'PSC sync records' do
          let(:redis) { Rails.application.redis }
          let(:ns) { 'NcsNavigator::Core::Warehouse::OperationalImporter' }

          before do
            keys = redis.keys('*')
            redis.del(*keys) unless keys.empty?

            f_e3.event_end_date = '2010-09-08'
            save_wh(f_e3)

            do_import
          end

          it "stores a set of participants that need to be sync'd" do
            redis.smembers("#{ns}:psc_sync:participants").sort.
              should == %w(fred_p ginger_p)
          end

          it "stores a list of events that need to be sync'd for each participant" do
            redis.smembers("#{ns}:psc_sync:p:fred_p:events").
              should == %w(f_e1 f_e2 f_e3 f_e4)
          end

          it "stores a set of link contacts without instruments that need to be sync'd for each p" do
            redis.smembers("#{ns}:psc_sync:p:fred_p:link_contacts_without_instrument").sort.
              should == %w(f_c1_e1 f_c1_e3 f_c2_e3 f_c3_e4)
          end

          it "stores a set of link contacts with instruments that need to be sync'd for each p" do
            redis.smembers("#{ns}:psc_sync:p:fred_p:link_contacts_with_instrument:f_e2_i").
              should == %w(f_c1_e2)
          end

          describe 'an event hash' do
            let(:event_hash) { redis.hgetall("#{ns}:psc_sync:event:f_e3") }

            it 'has the status' do
              event_hash['status'].should == 'new'
            end

            it 'has the event ID' do
              event_hash['event_id'].should == 'f_e3'
            end

            it 'has the event start date' do
              event_hash['start_date'].should == '2010-09-03'
            end

            it 'has the event end date' do
              event_hash['end_date'].should == '2010-09-08'
            end

            it 'has the event type code' do
              event_hash['event_type_code'].should == '10'
            end

            it 'has the event type label' do
              event_hash['event_type_label'].should == 'informed_consent'
            end

            it 'knows whether the person is hi or lo' do
              event_hash['recruitment_arm'].should == 'lo'
            end

            it 'has the sort key' do
              event_hash['sort_key'].should == '2010-09-03:010'
            end
          end

          describe 'a link_contact hash' do
            describe 'with an instrument' do
              let(:lc_hash) { redis.hgetall("#{ns}:psc_sync:link_contact:f_c1_e2") }

              it 'has the status' do
                lc_hash['status'].should == 'new'
              end

              it 'has the link_contact ID' do
                lc_hash['contact_link_id'].should == 'f_c1_e2'
              end

              it 'has the contact date' do
                lc_hash['contact_date'].should == '2010-09-03'
              end

              it 'has the contact ID' do
                lc_hash['contact_id'].should == 'f_c1'
              end

              it 'has the event ID' do
                lc_hash['event_id'].should == 'f_e2'
              end

              it 'has the instrument ID' do
                lc_hash['instrument_id'].should == 'f_e2_i'
              end

              it 'has the instrument type' do
                lc_hash['instrument_type'].should == '5'
              end

              it 'knows if the instrument was complete' do
                lc_hash['instrument_status'].should == 'not started'
              end

              it 'has the sort key' do
                lc_hash['sort_key'].should == 'f_e2:2010-09-03:005'
              end
            end

            describe 'without an instrument' do
              let(:lc_hash) { redis.hgetall("#{ns}:psc_sync:link_contact:f_c1_e3") }

              it 'does not have an instrument type' do
                lc_hash['instrument_type'].should be_nil
              end

              it 'has the appropriate sort key' do
                lc_hash['sort_key'].should == 'f_e3:2010-09-03'
              end
            end
          end
        end
      end
    end
  end
end
