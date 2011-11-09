require 'spec_helper'

require 'ncs_navigator/core/warehouse/transformer'

module NcsNavigator::Core::Warehouse
  describe Transformer, :clean_with_truncation, :slow do
    MdesModule = NcsNavigator::Warehouse::Models::TwoPointZero

    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = File.join(Rails.root, 'log/wh.log')
        config.set_up_logs
        config.output_level = :quiet
      end
    }

    it 'can be created' do
      Transformer.create_transformer(wh_config).should_not be_nil
    end

    it 'uses the correct bcdatabase config' do
      Transformer.bcdatabase[:name].should == 'ncs_navigator_core'
    end

    let(:bcdatabase_config) {
      if Rails.env == 'ci'
        { :group => 'public_ci_postgresql9' }
      else
        { :name => 'ncs_navigator_core_test' }
      end
    }
    let(:enumerator) {
      Transformer.new(wh_config, :bcdatabase => bcdatabase_config)
    }
    let(:producer_names) { [] }
    let(:results) { enumerator.to_a(*producer_names) }

    def self.code(i)
      Factory(:ncs_code, :local_code => i)
    end

    shared_examples 'one to one' do
      it 'creates one record per source entry' do
        results.collect(&:class).should == [warehouse_model]
      end
    end

    shared_context 'mapping test' do
      before do
        # ignore unused so we can see the mapping failures
        Transformer.on_unused_columns :ignore
      end

      after do
        Transformer.on_unused_columns :fail
      end

      def verify_mapping(core_field, core_value, wh_field, wh_value=nil)
        wh_value ||= core_value
        core_model.last.tap { |p| p.send("#{core_field}=", core_value) }.save!
        results.last.send(wh_field).should == wh_value
      end

      def self.verify_mapping(core_field, core_value, wh_field, wh_value=nil)
        it "maps #{core_field} to #{wh_field}" do
          verify_mapping(core_field, core_value, wh_field, wh_value)
        end
      end
    end

    describe 'for ListingUnit' do
      let(:producer_names) { [:listing_units] }
      let(:warehouse_model) { MdesModule::ListingUnit }

      before do
        Factory(:listing_unit)
      end

      include_examples 'one to one'
    end

    describe 'for DwellingUnit' do
      let(:producer_names) { [:dwelling_units] }
      let(:warehouse_model) { MdesModule::DwellingUnit }

      before do
        Factory(:dwelling_unit)
      end

      include_examples 'one to one'

      it 'uses the public ID for the listing unit' do
        results.first.list_id.should == ListingUnit.first.list_id
      end
    end

    describe 'for DwellingHouseholdLink' do
      let(:producer_names) { [:dwelling_household_links] }
      let(:warehouse_model) { MdesModule::LinkHouseholdDwelling }

      before do
        Factory(:dwelling_household_link)
      end

      include_examples 'one to one'

      it 'uses the public ID for the dwelling unit' do
        results.first.du_id.should == DwellingUnit.first.du_id
      end

      it 'uses the public ID for the household unit' do
        results.first.hh_id.should == HouseholdUnit.first.hh_id
      end
    end

    describe 'for HouseholdUnit' do
      let(:producer_names) { [:household_units] }
      let(:warehouse_model) { MdesModule::HouseholdUnit }
      let(:core_model) { HouseholdUnit }

      before do
        Factory(:household_unit)
      end

      include_examples 'one to one'

      describe 'with manually determined variables' do
        include_context 'mapping test'

        [
          [:hh_eligibility,               code(7), :hh_elig,         '7'],
          [:number_of_age_eligible_women,      11, :num_age_elig,   '11'],
          [:number_of_pregnant_women,           4, :num_preg,        '4'],
          [:number_of_pregnant_minors,          1, :num_preg_minor,  '1'],
          [:number_of_pregnant_adults,          3, :num_preg_adult,  '3'],
          [:number_of_pregnant_over49,          0, :num_preg_over49, '0']
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for HouseholdPersonLink' do
      let(:producer_names) { [:household_person_links] }
      let(:warehouse_model) { MdesModule::LinkPersonHousehold }

      before do
        Factory(:household_person_link)
      end

      include_examples 'one to one'

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.person_id
      end

      it 'uses the publid ID for household' do
        results.first.hh_id.should == HouseholdUnit.first.hh_id
      end
    end

    describe 'for Person' do
      let(:core_model) { Person }

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
        include_context 'mapping test'

        [
          [:marital_status,                 code(9),     :maristat,     '9'],
          [:marital_status_other,           'On fire',   :maristat_oth],
          [:language,                       code(4),     :person_lang,  '4'],
          [:language_other,                 'Esperanto', :person_lang_oth],
          [:preferred_contact_method,       code(1),     :pref_contact, '1'],
          [:preferred_contact_method_other, 'Pigeon',    :pref_contact_oth],
          [:planned_move,                   code(4),     :plan_move,    '4'],
        ].each do |core_field, core_value, wh_field, wh_value|
          verify_mapping(core_field, core_value, wh_field, wh_value)
        end
      end

      describe 'direct link to participant' do
        before do
          pending 'Might not be necessary'

          Factory(:participant, :p_id => 'the-participant-id', :person => Person.first)

          producer_names.clear << :link_participant_self_person
        end

        it 'derives the ID from the participant ID' do
          results.first.person_pid_id.should == 'the-participant-id-self'
        end

        it 'has the correct person_id' do
          results.first.person_id.should == Person.first.person_id
        end

        it 'has the correct p_id' do
          results.first.p_id.should == Participant.first.p_id
        end

        it 'relation is self' do
          results.first.relation.should == '1'
        end

        it 'is active' do
          results.first.is_active.should == '1'
        end

        it 'only generates if there is a participant' do
          results.size.should == 1
        end
      end

      describe 'and ParticipantPersonLink' do
        let(:participant) { Participant.first }
        let(:person) { Person.last }

        before do
          Factory(:participant)
          Factory(:participant_person_link,
            :participant => participant, :person => person)

          producer_names.clear << :participant_person_links
        end

        it 'generates one link per source link' do
          results.size.should == 1
        end

        it 'uses the public ID for participant' do
          results.first.p_id.should == participant.p_id
        end

        it 'uses the public ID for person' do
          results.first.person_id.should == person.person_id
        end

        it 'uses the public ID for the link itself' do
          results.first.person_pid_id.should == ParticipantPersonLink.first.person_pid_id
        end
      end
    end

    describe 'for PersonRace' do
      before do
        Factory(:person)
        Factory(:person_race, :person => Person.first)
        Factory(:person_race, :person => Person.first,
          :race => Factory(:ncs_code, :local_code => 2))

        producer_names << :person_races
      end

      it 'generates one person_race per source record' do
        results.size.should == 2
      end

      it 'uses the correct code for each record' do
        results.collect(&:race).should == %w(1 2)
      end

      it 'has the correct person_id' do
        results.first.person_id.should == Person.first.person_id
      end
    end

    describe 'for Participant' do
      let(:core_model) { Participant }

      before do
        Factory(:participant)

        producer_names << :participants
      end

      it 'generates one participant per source record' do
        results.size.should == 1
      end

      describe 'manually mapped variables' do
        include_context 'mapping test'

        [
          [:pid_age_eligibility, code(8), :pid_age_elig, '8']
        ].each do |core_field, core_value, wh_field, wh_value|
          it "maps #{core_field} to #{wh_field}" do
            verify_mapping(core_field, core_value, wh_field, wh_value)
          end
        end
      end
    end

    describe 'for ParticipantConsent' do
      before do
        Factory(:participant_consent)
        producer_names << :participant_consents
      end

      it 'generates one consent per source record' do
        results.collect(&:class).should == [MdesModule::ParticipantConsent]
      end

      it "uses the participant's public ID" do
        results.first.p_id.should == Participant.first.p_id
      end
    end

    describe 'for ParticipantConsentSample' do
      before do
        Factory(:participant_consent_sample)
        producer_names << :participant_consent_samples
      end

      it 'generates one per source record' do
        results.collect(&:class).should == [MdesModule::ParticipantConsentSample]
      end

      it "uses the participant's public ID" do
        results.first.p_id.should == Participant.first.p_id
      end

      it "uses the participant consent's public ID" do
        results.first.participant_consent_id.should ==
          ParticipantConsent.first.participant_consent_id
      end
    end

    describe 'for ParticipantAuthorizationForm' do
      let(:producer_names) { [:participant_authorization_forms] }

      before do
        Factory(:participant_authorization_form)
      end

      it 'generates one per source record' do
        results.collect(&:class).should == [MdesModule::ParticipantAuth]
      end

      it 'uses the public ID for participant' do
        results.first.p_id.should == Participant.first.p_id
      end

      it 'uses the public ID for contact' do
        results.first.contact_id.should == Contact.first.contact_id
      end

      it 'uses the public ID for provider' do
        pending 'No providers yet'
        results.first.provider_id.should == Provider.first.provider_id
      end
    end

    describe 'for ParticipantVisitConsent' do
      let(:producer_names) { [:participant_visit_consents] }
      let(:consenter) { Factory(:person, :first_name => 'Ginger') }

      before do
        Factory(:participant_visit_consent, :vis_person_who_consented => consenter)
      end

      it 'generates one per source record' do
        results.collect(&:class).should == [MdesModule::ParticipantVisConsent]
      end

      it 'uses the public ID for the participant' do
        results.first.p_id.should == Participant.first.p_id
      end

      it 'uses the public ID for the person who consented' do
        results.first.vis_person_who_consented_id.should == consenter.person_id
      end

      it 'uses the public ID for the contact' do
        results.first.contact_id.should == Contact.first.contact_id
      end
    end

    describe 'for ParticipantVisitRecord' do
      let(:producer_names) { [:participant_visit_records] }
      let(:visited) { Factory(:person, :first_name => 'Ginger') }

      before do
        Factory(:participant_visit_record, :rvis_person => visited)
      end

      it 'generates one per source record' do
        results.collect(&:class).should == [MdesModule::ParticipantRvis]
      end

      it 'uses the public ID for the participant' do
        results.first.p_id.should == Participant.first.p_id
      end

      it 'uses the public ID for the person visited' do
        results.first.rvis_person.should == visited.person_id
      end

      it 'uses the public ID for the contact' do
        results.first.contact_id.should == Contact.first.contact_id
      end
    end

    describe 'for PpgDetail' do
      let(:producer_names) { [:ppg_details] }
      let(:warehouse_model) { MdesModule::PpgDetails }

      let!(:ppg_detail) { Factory(:ppg_detail) }

      include_examples 'one to one'

      it 'uses the public ID for the participant' do
        results.first.p_id.should == Participant.first.p_id
      end
    end

    describe 'for PpgStatusHistory' do
      let(:producer_names) { [:ppg_status_histories] }
      let(:warehouse_model) { MdesModule::PpgStatusHistory }

      let!(:ppg_status_history) { Factory(:ppg_status_history) }

      include_examples 'one to one'

      it 'uses the public ID for the participant' do
        results.first.p_id.should == Participant.first.p_id
      end
    end

    describe 'for Address' do
      let(:producer_names) { [:addresses] }
      let(:warehouse_model) { MdesModule::Address }
      let(:core_model) { Address }
      let!(:address) { Factory(:address) }

      include_examples 'one to one'

      it 'uses the public ID for the person' do
        results.first.person_id.should == Person.first.person_id
      end

      # TODO: person_id and du_id should be mutually exclusive
      it 'uses the public ID for the DU' do
        results.first.du_id.should == DwellingUnit.first.du_id
      end

      it 'uses the public ID for the provider' do
        pending 'No Provider in core yet'
      end

      it 'uses the public ID for the institute' do
        pending 'No Institute in core yet'
      end

      it 'renders address_info_date appropriately' do
        address.tap { |a| a.address_info_date = Date.new(2010, 3, 4) }.save!
        results.first.address_info_date.should == '2010-03-04'
      end

      it 'renders address_info_update appropriately' do
        address.tap { |a| a.address_info_update = Date.new(2011, 9, 4) }.save!
        results.first.address_info_update.should == '2011-09-04'
      end

      context 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:address_one, '2702 High St.', :address_1],
          [:address_two, 'Floor 23',      :address_2]
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for Email' do
      let(:producer_names) { [:emails] }
      let(:warehouse_model) { MdesModule::Email }
      let!(:email) { Factory(:email) }

      include_examples 'one to one'

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.person_id
      end

      it 'uses the public ID for the provider' do
        pending 'No Provider in core yet'
      end

      it 'uses the public ID for the institute' do
        pending 'No Institute in core yet'
      end

      it 'renders email_info_date appropriately' do
        email.tap { |a| a.email_info_date = Date.new(2010, 3, 4) }.save!
        results.first.email_info_date.should == '2010-03-04'
      end

      it 'renders email_info_update appropriately' do
        email.tap { |a| a.email_info_update = Date.new(2011, 9, 4) }.save!
        results.first.email_info_update.should == '2011-09-04'
      end
    end

    describe 'for Telephone' do
      let(:producer_names) { [:telephones] }
      let(:warehouse_model) { MdesModule::Telephone }
      let!(:telephone) { Factory(:telephone) }

      include_examples 'one to one'

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.person_id
      end

      it 'uses the public ID for the provider' do
        pending 'No Provider in core yet'
      end

      it 'uses the public ID for the institute' do
        pending 'No Institute in core yet'
      end

      it 'renders phone_info_date appropriately' do
        telephone.tap { |a| a.phone_info_date = Date.new(2010, 3, 4) }.save!
        results.first.phone_info_date.should == '2010-03-04'
      end

      it 'renders email_info_update appropriately' do
        telephone.tap { |a| a.phone_info_update = Date.new(2011, 9, 4) }.save!
        results.first.phone_info_update.should == '2011-09-04'
      end
    end

    describe 'for Instrument' do
      let(:producer_names) { [:instruments] }
      let(:warehouse_model) { MdesModule::Instrument }
      let(:core_model) { Instrument }

      let!(:instrument) { Factory(:instrument) }

      include_examples 'one to one'

      it 'uses the public ID for event' do
        results.first.event_id.should == Event.first.event_id
      end

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:instrument_start_date, Date.new(2009, 5, 8), :ins_date_start, '2009-05-08'],
          [:instrument_start_time, '23:30',              :ins_start_time],
          [:instrument_end_date,   Date.new(2009, 5, 9), :ins_date_end,   '2009-05-09'],
          [:instrument_end_time,   '01:30',              :ins_end_time],
          [:instrument_breakoff,   code(2),              :ins_breakoff,   '2'],
          [:instrument_status,     code(4),              :ins_status,     '4'],
          [:instrument_mode,       code(2),              :ins_mode,       '2'],
          [:instrument_mode_other, 'Helicopter drop',    :ins_mode_oth],
          [:instrument_method,     code(1),              :ins_method,     '1'],
          [:instrument_comment,    'Confused',           :instru_comment],
          [:supervisor_review,     code(1),              :sup_review,     '1']
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for Event' do
      let(:producer_names) { [:events] }
      let(:warehouse_model) { MdesModule::Event }
      let(:core_model) { Event }

      let!(:event) { Factory(:event) }

      include_examples 'one to one'

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:event_disposition,          5,                        :event_disp],
          [:event_disposition_category, code(4),                  :event_disp_cat,    '4'],
          [:event_incentive_cash,       BigDecimal.new('7.11'), :event_incent_cash, '7.11'],
          [:event_incentive_noncash,    'Chick-fil-a coupons',    :event_incent_noncash]
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for Contact' do
      let(:producer_names) { [:contacts] }
      let(:warehouse_model) { MdesModule::Contact }
      let(:core_model) { Contact }

      let!(:contact) { Factory(:contact) }

      include_examples 'one to one'

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:contact_disposition,    7,         :contact_disp, '7'],
          [:contact_language,       code(10),  :contact_lang, '10'],
          [:contact_language_other, 'Klingon', :contact_lang_oth],
          [:who_contacted_other,    'Cat',     :who_contact_oth]
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for ContactLink' do
      let(:producer_names) { [:contact_links] }
      let(:warehouse_model) { MdesModule::LinkContact }
      let(:core_model) { ContactLink }

      let!(:contact_link) { Factory(:contact_link) }

      include_examples 'one to one'

      it 'uses the public ID for contact' do
        results.first.contact_id.should == Contact.first.contact_id
      end

      it 'uses the public ID for event' do
        results.first.event_id.should == Event.first.event_id
      end

      it 'uses the public ID for instrument' do
        results.first.instrument_id.should == Instrument.first.instrument_id
      end

      it 'uses the public ID for staff' do
        pending 'Core has no separate concept of staff'
      end

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.person_id
      end

      it 'uses the public ID for provider' do
        pending 'No Provider in core yet'
      end
    end

    describe "a producer's metadata" do
      let(:producer) { Transformer.record_producers.find { |rp| rp.name == :participants } }
      let(:column_map) { producer.column_map(Participant.attribute_names) }

      it 'includes the MDES model' do
        producer.model.should == MdesModule::Participant
      end

      it 'includes a column map' do
        lambda { column_map }.should_not raise_error
      end

      describe 'column map' do
        it 'includes explicit mappings' do
          column_map['pid_age_eligibility_code'].should == 'pid_age_elig'
        end

        it 'includes heuristic mappings' do
          column_map['p_type_other'].should == 'p_type_oth'
        end
      end
    end
  end
end
