# -*- coding: utf-8 -*-


require 'spec_helper'

require 'ncs_navigator/core/warehouse'

require File.expand_path('../importer_warehouse_setup', __FILE__)

module NcsNavigator::Core::Warehouse
  describe OperationalImporter, :clean_with_truncation, :warehouse do
    include_context :importer_spec_warehouse

    let(:importer) {
      OperationalImporter.new(wh_config, importer_options)
    }

    let(:importer_options) { { } }

    let(:enumerator_class) {
      OperationalEnumerator.select_implementation(wh_config)
    }

    let(:enumerator) {
      enumerator_class.new(wh_config, :bcdatabase => bcdatabase_config)
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
      record
    end

    def create_warehouse_record_with_defaults(mdes_model, attributes={})
      all_attrs = all_missing_attributes(mdes_model).
        merge(test_defaults_for(mdes_model)).
        merge(attributes)

      save_wh(mdes_model.new(all_attrs))
    end

    def test_defaults_for(mdes_model)
      {
        :staff_id => 'staff_public_id',
        :relation => '1',
        :instrument_repeat_key => '0'
      }.inject({}) do |d, (prop_name, default_value)|
        if mdes_model.properties[prop_name]
          d[prop_name] = default_value
        end
        d
      end
    end

    describe 'strategy selection' do
      it 'handles most models automatically' do
        importer.automatic_producers.size.should == 30
      end

      [
        :LinkContact, :Event, :Instrument
      ].each do |manual|
        it "handles #{manual} manually" do
          importer.automatic_producers.collect { |ap| ap.model(wh_config) }.
            should_not include(wh_config.model(manual))
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
            NcsCode.for_list_name_and_local_code('MARITAL_STATUS_CL1', 4)
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
          let!(:core_address) { Factory(:mdes_min_address, :person => core_person) }
          let!(:mdes_address) { enumerator.to_a(:addresses).first.tap { |a| save_wh(a) } }

          # Matches the ssu_ids used in the factories
          let!(:ssu) { create_warehouse_record_with_defaults(wh_config.model(:Ssu), :ssu_id => '42') }

          before do
            second_person = Factory(:person, :last_name => 'MacMurray')
            save_wh(enumerator.to_a(:people).find { |p| p.last_name == second_person.last_name })

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

        describe 'auditing' do
          let(:audit_records) {
            Version.where(
              :item_type => Person.to_s,
              :item_id => core_person.id,
              :event => 'update'
              )
          }

          before do
            mdes_person.last_name = 'Astaire'
            save_wh(mdes_person)

            with_versioning { importer.import(:people) }
          end

          it 'happens' do
            audit_records.size.should == 1
          end

          it 'indicates that the record came from the importer' do
            audit_records.first.whodunnit.should == 'operational_importer'
          end
        end
      end

      describe 'of a completely new record' do
        let!(:core_person) { Factory(:person, :person_id => 'P47') }

        let!(:mdes_address) {
          core_address = Factory(:mdes_min_address,
            :address_id => 'A7', :address_one => '123 Anymain Dr.',
            :person => core_person)
          create_warehouse_record_for_core_record(core_address)
        }

        before do
          with_versioning { importer.import(:addresses) }
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

        describe 'auditing' do
          let(:audit_records) {
            Version.where(:item_type => Address.to_s, :item_id => Address.first.id)
          }

          it 'happens' do
            audit_records.size.should == 1
          end

          it 'indicates that the record came from the importer' do
            audit_records.first.whodunnit.should == 'operational_importer'
          end
        end
      end

      describe 'resolving associations' do
        let(:auto_names) { importer.automatic_producers.collect(&:name) }

        describe 'backward' do
          let!(:mdes_person) { create_warehouse_record_via_core(Person, 'P24') }
          let!(:mdes_link) {
            create_warehouse_record_via_core(ParticipantPersonLink, 'LP42',
              :person => mdes_person)
          }

          before do
            # test setup
            auto_names.index(:people).should < auto_names.index(:participant_person_links)
            importer.import(:people, :participants, :participant_person_links)
          end

          it 'works' do
            ParticipantPersonLink.find_by_person_pid_id('LP42').person.should ==
              Person.find_by_person_id('P24')
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
          create_warehouse_record_for_core_record(core_record)
        }

        it 'works' do
          importer.import(core_table)
          core_model.count.should == 1
        end
      end

      describe 'of core model' do
        # Matches the ssu_ids used in the factories
        let!(:ssu) { create_warehouse_record_with_defaults(wh_config.model(:Ssu), :ssu_id => '42') }

        # with no special data needs
        [
          ListingUnit, DwellingUnit, DwellingHouseholdLink, HouseholdUnit, HouseholdPersonLink,
          Person, PersonRace, ParticipantPersonLink,
          Participant, ParticipantConsentSample,
          # participant authorization form requires a provider in the MDES
          # ParticipantAuthorizationForm,
          PpgStatusHistory,
          Address, Email,
          NonInterviewReport, NoAccessNonInterviewReport, DwellingUnitTypeNonInterviewReport,
          RefusalNonInterviewReport, VacantNonInterviewReport
        ].each do |core_model|
          describe core_model do
            let(:core_model) { core_model }

            include_context 'basic model import test'
          end
        end

        # Temporarily separated because of provider ref in factory until providers are enumerated
        describe Telephone do
          include_context 'basic model import test'

          let(:core_model) { Telephone }
          let(:core_record) { Factory(:telephone, :provider => nil) }
        end

        describe PpgDetail do
          let(:core_model) { PpgDetail }
          include_context 'basic model import test'

          it 'does not create a status history record' do
            initial_history_count = PpgStatusHistory.count
            importer.import(core_table)
            initial_history_count.should == PpgStatusHistory.count
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
          let(:core_record) {
            Factory(:participant_visit_record, :rvis_person => visited)
          }
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

    describe 'correcting PPG status history' do
      let(:participant) {
        create_warehouse_record_with_defaults(wh_config.model(:Participant), :p_id => 'elf')
      }

      let(:ppg_first) { '2' }
      let!(:ppg_details) {
        create_warehouse_record_with_defaults(wh_config.model(:PpgDetails),
          :ppg_first => ppg_first, :p => participant)
      }

      let!(:ppg_status_history_current) {
        create_warehouse_record_with_defaults(wh_config.model(:PpgStatusHistory),
          :p => participant, :ppg_status => '1', :ppg_status_date => '2011-06-04')
      }

      let!(:staff) {
        create_warehouse_record_with_defaults(wh_config.model(:Staff), :staff_id => 'SPI')
      }

      let(:screener_date) { '2010-03-06' }
      let!(:screener_event) {
        create_warehouse_record_with_defaults(wh_config.model(:Event),
          :participant => participant, :event_type => 29,
          :event_start_date => '2010-03-04', :event_end_date => screener_date)
      }
      let(:screener_contact_1) {
        create_warehouse_record_with_defaults(wh_config.model(:Contact), :contact_id => '1',
          :contact_type => '2', :contact_date => '2010-03-05')
      }
      let(:screener_contact_2) {
        create_warehouse_record_with_defaults(wh_config.model(:Contact), :contact_id => '2',
          :contact_type => '3', :contact_date => '2010-03-06')
      }
      let!(:screener_lc_1) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkContact), :contact_link_id => '1',
          :contact => screener_contact_1, :event => screener_event, :staff => staff)
      }
      let!(:screener_lc_2) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkContact), :contact_link_id => '2',
          :contact => screener_contact_2, :event => screener_event, :staff => staff)
      }

      describe 'when the source history is correct' do
        it 'leaves the history alone' do
          create_warehouse_record_with_defaults(wh_config.model(:PpgStatusHistory),
            :ppg_history_id => 'existing',
            :p => participant, :ppg_status => ppg_first, :ppg_status_date => screener_date)

          importer.import(:ppg_status_histories)

          PpgStatusHistory.order(:ppg_status_date).collect(&:ppg_status_code).should == [2, 1]
        end
      end

      shared_context 'new history entry' do
        let(:first_history_entry) {
          PpgStatusHistory.order(:ppg_status_date).first
        }

        it 'inserts a new history record' do
          PpgStatusHistory.order(:ppg_status_date).collect(&:ppg_status_code).
            should == expected_statuses
        end

        it 'uses the screener end date as the date for the new status history entry' do
          first_history_entry.ppg_status_date.should == screener_date
        end

        it 'notes that status was obtained from the participant (as part of the screener)' do
          first_history_entry.ppg_info_source_code.should == 1
        end

        it 'notes that status was obtained in the same mode as the pregnancy screener' do
          first_history_entry.ppg_info_mode_code.should == 3
        end

        it 'provides a comment indicating it was inferred' do
          first_history_entry.ppg_comment.should ==
            'Missing history entry inferred from ppg_details.ppg_first during import into NCS Navigator.'
        end

        it 'has the PSU ID set' do
          first_history_entry.psu_code.should == 20000030
        end
      end

      describe 'when the source history is missing the initial status' do
        let(:expected_statuses) { [2, 1] }

        before do
          importer.import(:participants, :ppg_status_histories)
        end

        include_context 'new history entry'
      end

      describe 'when the source history is empty' do
        let(:expected_statuses) { [2] }

        before do
          ppg_status_history_current.destroy
          wh_config.model(:PpgStatusHistory).count.should == 0

          importer.import(:participants, :ppg_status_histories)
        end

        include_context 'new history entry'
      end

      it 'only attempts to correct for the first ppg_details for a participant' do
        pending '#1953'
      end
    end

    describe 'participant being-followedness' do
      let!(:src_participant) {
        create_warehouse_record_with_defaults(wh_config.model(:Participant),
          :p_id => 'zed', :p_type => p_type, :enroll_status => enroll_status)
      }

      def should_be_followed
        importer.import(:participants, :ppg_details, :ppg_status_histories)
        Participant.count.should == 1
        Participant.first.being_followed.should be_true
      end

      def should_not_be_followed
        importer.import(:participants, :ppg_details, :ppg_status_histories)
        Participant.count.should == 1
        Participant.first.being_followed.should be_false
      end

      describe 'when automatically determined' do
        before do
          importer_options[:followed_p_ids] = nil
        end

        %w(1 2 3).each do |mother_type|
          describe "for a mother of type #{mother_type}" do
            let(:p_type) { mother_type }

            let!(:ppg_details) {
              create_warehouse_record_with_defaults(wh_config.model(:PpgDetails),
                :ppg_first => '2', :p => src_participant)
            }

            let!(:ppg_status_history_current) {
              create_warehouse_record_with_defaults(wh_config.model(:PpgStatusHistory),
                :p => src_participant, :ppg_status => '2', :ppg_status_date => '2011-06-04')
            }

            let(:ppg_pregnant) { '1' }

            describe 'when she is enrolled' do
              let(:enroll_status) { '1' }

              it 'is true when she was pregnant when originally contacted' do
                ppg_details.ppg_first = ppg_pregnant
                save_wh(ppg_details)

                should_be_followed
              end

              it 'is true when she has a pregnancy in her status history' do
                create_warehouse_record_with_defaults(wh_config.model(:PpgStatusHistory),
                  :ppg_history_id => 'Older',  :p => src_participant,
                  :ppg_status => ppg_pregnant, :ppg_status_date => '2010-01-05')

                should_be_followed
              end

              it 'is true when she is currently pregnant' do
                ppg_status_history_current.ppg_status = ppg_pregnant
                save_wh(ppg_status_history_current)

                should_be_followed
              end

              it 'is false when she was not originally pregnant and has no pregnancies in her history' do
                should_not_be_followed
              end

              it 'is false when she was not originally pregnant and has no status history' do
                ppg_status_history_current.destroy

                should_not_be_followed
              end

              it 'is false when she has no PPG details and no status history' do
                ppg_status_history_current.destroy
                ppg_details.destroy

                should_not_be_followed
              end
            end

            %w(2 -4).each do |not_enrolled_code|
              describe "when her enroll status is #{not_enrolled_code}" do
                let(:enroll_status) { not_enrolled_code }

                it "is false" do
                  ppg_details.ppg_first = '1'
                  save_wh(ppg_details)

                  should_not_be_followed
                end
              end
            end
          end
        end

        describe 'for a child' do
          let(:p_type) { '6' }

          describe 'when enrolled' do
            let(:enroll_status) { '1' }

            it 'is true regardless of PPG status' do
              should_be_followed
            end
          end

          %w(2 -4).each do |not_enrolled_code|
            describe "when the child's enroll status is #{not_enrolled_code}" do
              let(:enroll_status) { not_enrolled_code }

              it 'is false' do
                should_not_be_followed
              end
            end
          end
        end

        describe 'for a non-followed p_type' do
          let(:p_type) { '4' }

          describe 'when enrolled' do
            let(:enroll_status) { '1' }

            it 'is false' do
              should_not_be_followed
            end
          end

          %w(2 -4).each do |not_enrolled_code|
            describe "when enroll status is #{not_enrolled_code}" do
              let(:enroll_status) { not_enrolled_code }

              it 'is false' do
                should_not_be_followed
              end
            end
          end
        end
      end

      describe 'when explicitly enumerated' do
        shared_context 'explicitly enumerated followedness' do
          it 'follows the participant when its ID is in the list' do
            importer_options[:followed_p_ids] = ['foo', src_participant.p_id]

            should_be_followed
          end

          it 'does not follow the participant when its ID is not in the list' do
            importer_options[:followed_p_ids] = ['foo']

            should_not_be_followed
          end
        end

        describe 'and the heuristic would match' do
          let(:p_type) { 6 }
          let(:enroll_status) { 1 }

          include_context 'explicitly enumerated followedness'
        end

        describe 'and the heuristic would not match' do
          let(:p_type) { 4 }
          let(:enroll_status) { 2 }

          include_context 'explicitly enumerated followedness'
        end
      end
    end

    def create_warehouse_record_via_core(core_model, wh_id, wh_attributes={})
      factory_name = [
        "mdes_min_#{core_model.to_s.underscore}",
        core_model.to_s.underscore
      ].find { |candidate| FactoryGirl.factories.registered?(candidate) }

      core_record = Factory(factory_name, core_model.public_id_field => wh_id)

      create_warehouse_record_for_core_record(core_record, wh_attributes)
    end

    ##
    # n.b.: this method relies on all core MDES-mapped records having
    # distinct public IDs (i.e. even across types).
    def create_warehouse_record_for_core_record(core_record, wh_attributes={})
      core_records = [core_record]

      # event enumerator skips events w/o link contact
      surplus_ids = []
      if (core_record.class == Event)
        cl = Factory(:mdes_min_contact_link, :event_id => core_record.id)
        core_records.unshift cl
        surplus_ids << cl.public_id
      end

      core_instances = related_core_records(core_records).to_a

      # produce all related so that warehouse FKs are satisfied
      producer_names = core_instances.collect { |ci| ci.class.table_name.to_sym }.uniq
      producers = enumerator_class.record_producers.
        select { |rp| producer_names.include?(rp.name) }

      # produce in a transaction so that FK order doesn't matter
      producers.first.model(wh_config).transaction do
        enumerator.to_a(*producer_names).each do |mdes_rec|
          mdes_key = mdes_rec.key.first
          mdes_key_name = mdes_rec.class.key.first.name
          existing_mdes_rec = mdes_rec.class.first(mdes_key_name => mdes_key)

          if mdes_key == core_record.public_id
            mdes_rec = existing_mdes_rec if existing_mdes_rec
            mdes_rec.attributes = wh_attributes
            save_wh(mdes_rec)
          elsif surplus_ids.include?(mdes_key)
            # skip
          elsif core_instances.collect(&:public_id).include?(mdes_key)
            unless existing_mdes_rec
              save_wh(mdes_rec)
            end
          end
        end
      end
      core_records.each(&:destroy)

      prime_producer = producers.find { |rp| rp.name == core_record.class.table_name.to_sym }
      prime_producer.model(wh_config).first(prime_producer.model(wh_config).key.first.name => core_record.public_id)
    end

    def code_for_event_type(event_type_name)
      NcsNavigatorCore.mdes.types.
        find { |type| type.name == 'event_type_cl1' }.code_list.
        find { |cle| cle.label == event_type_name }.value
    end

    def code_for_instrument_type(instrument_type_name)
      NcsNavigatorCore.mdes.types.
        find { |type| type.name == 'instrument_type_cl1' }.code_list.
        find { |cle| cle.label == instrument_type_name }.value
    end

    ##
    # Finds all unique core records associated with any of the input
    # records. This follows associations to the full depth of the graph.
    def related_core_records(core_records, found=[])
      core_records.each do |core_record|
        found << core_record
        core_record.class.reflect_on_all_associations.each do |association|

          values = if association.collection?
                     core_record.send(association.name)
                   else
                     [core_record.send(association.name)].compact
                   end

          values.each do |associated_value|
            next unless associated_value.class.ancestors.include?(NcsNavigator::Core::Mdes::MdesRecord)
            related_core_records([associated_value], found) unless found.include?(associated_value)
          end
        end
      end
      found
    end

    describe 'Event, LinkContact, and Instrument', :slow, :redis do
      before do
        Event.count.should == 0
      end

      let(:fred_p) {
        create_warehouse_record_with_defaults(wh_config.model(:Participant),
          :p_id => 'fred_p', :enroll_status => '1')
      }
      let(:ginger_p) {
        create_warehouse_record_with_defaults(wh_config.model(:Participant),
          :p_id => 'ginger_p', :enroll_status => '2')
      }

      let(:fred_pers) {
        create_warehouse_record_with_defaults(wh_config.model(:Person), :person_id => 'fred_pers')
      }
      let(:ginger_pers) {
        create_warehouse_record_with_defaults(wh_config.model(:Person), :person_id => 'ginger_pers')
      }

      let!(:fake_staff) {
        create_warehouse_record_with_defaults(wh_config.model(:Staff), :staff_id => 'staff_public_id')
      }

      let!(:fred_p_pers_link) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkPersonParticipant),
          :person_pid_id => 'fred_p_pers_link',
          :p => fred_p,
          :person => fred_pers)
      }
      let!(:ginger_p_pers_link) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkPersonParticipant),
          :person_pid_id => 'ginger_p_pers_link',
          :p => ginger_p,
          :person => ginger_pers)
      }

      let!(:f_consent) {
        create_warehouse_record_with_defaults(wh_config.model(:ParticipantConsent),
          :participant_consent_id => 'f_consent', :consent_date => '2011-02-03',
          :p => fred_p, :consent_given => '1', :consent_type => '7', :consent_form_type => '7')
      }

      let(:f_e2) {
        create_warehouse_record_with_defaults(wh_config.model(:Event),
          :event_id => 'f_e2',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Pregnancy Screener'),
          :event_start_date => '2010-09-03')
      }
      let!(:f_e2_i) {
        create_warehouse_record_with_defaults(wh_config.model(:Instrument),
          :instrument_id => 'f_e2_i',
          :instrument_type => code_for_instrument_type('Pregnancy Screener Interview (HI,LI)'),
          :ins_status => 1,
          :event => f_e2)
      }
      let(:f_e3) {
        create_warehouse_record_with_defaults(wh_config.model(:Event),
          :event_id => 'f_e3',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Pregnancy Probability'),
          :event_start_date => '2010-09-03')
      }
      let(:f_e1) {
        create_warehouse_record_with_defaults(wh_config.model(:Event),
          :event_id => 'f_e1',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Low Intensity Data Collection'),
          :event_start_date => '9666-96-96')
      }
      let(:f_c1) {
        create_warehouse_record_with_defaults(wh_config.model(:Contact),
          :contact_id => 'f_c1', :contact_date => '2010-09-03')
      }
      let!(:f_c1_e1) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkContact),
          :contact_link_id => 'f_c1_e1',
          :contact => f_c1, :event => f_e1, :instrument => nil)
      }
      let!(:f_c1_e2) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkContact),
          :contact_link_id => 'f_c1_e2',
          :contact => f_c1, :event => f_e2, :instrument => f_e2_i)
      }
      let!(:f_c1_e3) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkContact),
          :contact_link_id => 'f_c1_e3',
          :contact => f_c1, :event => f_e3, :instrument => nil)
      }
      let(:f_c2) {
        create_warehouse_record_with_defaults(wh_config.model(:Contact),
          :contact_id => 'f_c2', :contact_date => '2010-09-17')
      }
      let!(:f_c2_e3) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkContact),
          :contact_link_id => 'f_c2_e3',
          :contact => f_c2, :event => f_e3, :instrument => nil)
      }

      let(:f_e4) {
        create_warehouse_record_with_defaults(wh_config.model(:Event),
          :event_id => 'f_e4',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Pregnancy Probability'),
          :event_start_date => '2011-03-09')
      }
      let(:f_c3) {
        create_warehouse_record_with_defaults(wh_config.model(:Contact),
          :contact_id => 'f_c3', :contact_date => '2011-03-08')
      }
      let!(:f_c3_e4) {
        create_warehouse_record_with_defaults(wh_config.model(:LinkContact),
          :contact_link_id => 'f_c3_e4',
          :contact => f_c3, :event => f_e4, :instrument => nil)
      }

      let!(:f_e5) {
        create_warehouse_record_with_defaults(wh_config.model(:Event),
          :event_id => 'f_e5',
          :participant => fred_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Informed Consent'),
          :event_start_date => '2011-01-08',
          :event_end_date => '2011-04-04')
      }

      let!(:g_e1) {
        create_warehouse_record_with_defaults(wh_config.model(:Event),
          :event_id => 'g_e1',
          :participant => ginger_p,
          :event_disp => 4,
          :event_type => code_for_event_type('Pregnancy Screener'),
          :event_start_date => '2010-11-07')
      }
      let!(:g_e1_i) {
        create_warehouse_record_with_defaults(wh_config.model(:Instrument),
          :instrument_id => 'g_e1_i',
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
          create_warehouse_record_with_defaults(wh_config.model(:Contact),
            :contact_id => 'g_c1', :contact_date => '2010-09-17')
        }
        let!(:g_c1_e1) {
          create_warehouse_record_with_defaults(wh_config.model(:LinkContact),
            :contact_link_id => 'g_c1_e1',
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
          create_warehouse_record_with_defaults(wh_config.model(:Contact),
            :contact_id => 'g_c1', :contact_date => '9777-97-97')
        }
        let!(:g_c1_e1) {
          create_warehouse_record_with_defaults(wh_config.model(:LinkContact),
            :contact_link_id => 'g_c1_e1', :contact => g_c1, :event => g_e1)
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

          it 'orders by the earliest set date date followed by the type' do
            events_for('fred_p').collect(&:event_id).should == %w(f_e2 f_e1 f_e3 f_e5 f_e4)
          end

          it 'includes events without link_contact' do
            events_for('ginger_p').first.event_id.should == 'g_e1'
          end
        end

        describe 'produced participant status history' do
          let(:participant) { Participant.find_by_p_id('fred_p') }

          let(:target_states) {
            participant.low_intensity_state_transition_audits.order(:id).collect(&:to).uniq
          }

          let(:expected_states) {
            %w(pending registered in_pregnancy_probability_group following_low_intensity)
          }

          context do
            before do
              do_import
            end

            it 'associates person with participant' do
              person = Person.find_by_person_id('fred_pers')
              person.should_not be_nil
              participant.should_not be_nil
              participant.participant_person_links.should_not be_empty
              participant.participant_person_links.first.person.should == person
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

          # without import in before
          context do
            describe 'low-high conversion' do
              it 'is taken if the participant has a consent with consent_type=1' do
                f_consent.consent_type = '1'
                save_wh(f_consent)

                do_import

                target_states.should == expected_states + ['moved_to_high_intensity_arm']
              end

              %w(1 2 6).each do |transition_consent_form_type|
                it "is taken if the participant has a consent with consent_form_type=#{transition_consent_form_type}" do
                  f_consent.consent_form_type = transition_consent_form_type
                  save_wh(f_consent)

                  do_import

                  target_states.should == expected_states + ['moved_to_high_intensity_arm']
                end
              end

              it 'is not taken if the participant consent was not given' do
                f_consent.consent_form_type = '1'
                f_consent.consent_given = '2'
                save_wh(f_consent)

                do_import

                target_states.should == expected_states
              end

              it 'is not taken if the participant only has consents of other types' do
                do_import

                target_states.should == expected_states
              end
            end
          end

          describe 'when transitioning into birth' do
            let!(:g_e3) {
              create_warehouse_record_with_defaults(wh_config.model(:Event),
                :event_id => 'g_e3',
                :participant => ginger_p,
                :event_disp => 4,
                :event_type => code_for_event_type('Informed Consent'),
                :event_start_date => '2010-11-08')
            }

            let!(:g_e8) {
              create_warehouse_record_with_defaults(wh_config.model(:Event),
                :event_id => 'g_e8',
                :participant => ginger_p,
                :event_disp => 4,
                :event_type => code_for_event_type('Birth'),
                :event_start_date => '2010-12-09')
            }

            before do
              do_import
            end

            it 'does not create a new PPG Status History' do
              PpgStatusHistory.all.should == []
            end
          end
        end

        it 'saves the events' do
          do_import
          Event.joins(:participant).where('participants.p_id' => 'fred_p').
            collect(&:event_id).sort.should == %w(f_e1 f_e2 f_e3 f_e4 f_e5)
        end

        it 'saves the contact_links' do
          do_import
          ContactLink.all.collect(&:contact_link_id).sort.should ==
            wh_config.model(:LinkContact).all.collect(&:contact_link_id).sort
        end

        it 'saves the instruments' do
          do_import
          wh_config.model(:Instrument).all.collect(&:instrument_id).sort.
            should == %w(f_e2_i g_e1_i)
        end

        describe 'PSC sync records' do
          let(:redis) { Rails.application.redis }
          let(:ns) { 'NcsNavigator::Core::Warehouse::OperationalImporter' }

          # Only followed participants get PSC records; make fred_p followed
          # via the ever-pregnant criterion.
          let!(:fred_p_ppg1) {
            create_warehouse_record_with_defaults(wh_config.model(:PpgDetails),
              :p => fred_p, :ppg_first => '1')
          }

          before do
            keys = redis.keys('*')
            redis.del(*keys) unless keys.empty?
          end

          describe 'participant selection' do
            it "stores a set of participants that need to be sync'd" do
              do_import

              redis.smembers("#{ns}:psc_sync:participants").should include('fred_p')
            end

            it "ignores participants that are not being followed" do
              do_import

              redis.smembers("#{ns}:psc_sync:participants").should_not include('ginger_p')
            end

            it "ignores child participants that are followed" do
              ginger_p.enroll_status = '1'
              ginger_p.p_type = '6'
              save_wh(ginger_p)

              do_import

              redis.smembers("#{ns}:psc_sync:participants").should_not include('ginger_p')
            end
          end

          context do
            before do
              f_e3.event_end_date = '2010-09-08'
              save_wh(f_e3)

              do_import
            end

            it "stores a list of events that need to be sync'd for each participant" do
              redis.smembers("#{ns}:psc_sync:p:fred_p:events").sort.
                should == %w(f_e1 f_e2 f_e3 f_e4 f_e5)
            end

            it "stores a set of link contacts that need to be sync'd for each event" do
              redis.smembers("#{ns}:psc_sync:p:fred_p:link_contacts:f_e3").sort.
                should == %w(f_c1_e3 f_c2_e3)
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
                event_hash['event_type_code'].should == '7'
              end

              it 'has the event type label' do
                event_hash['event_type_label'].should == 'pregnancy_probability'
              end

              it 'knows whether the person is hi or lo' do
                event_hash['recruitment_arm'].should == 'lo'
              end

              it 'has the sort key' do
                event_hash['sort_key'].should == '2010-09-03:007'
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

                it 'has the sort key' do
                  lc_hash['sort_key'].should == 'f_e2:2010-09-03'
                end
              end
            end
          end
        end
      end
    end
  end
end
