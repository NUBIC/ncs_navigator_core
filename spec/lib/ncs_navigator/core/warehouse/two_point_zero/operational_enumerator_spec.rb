# -*- coding: utf-8 -*-


require 'spec_helper'
require File.expand_path('../../operational_enumerator_spec_support', __FILE__)

require 'ncs_navigator/core/warehouse'

module NcsNavigator::Core::Warehouse::TwoPointZero
  describe OperationalEnumerator, :clean_with_truncation, :slow, :warehouse do
    let(:operational_enumerator_class) { OperationalEnumerator }

    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.mdes_version = '2.0'
        config.log_file = File.join(Rails.root, 'log/wh.log')
        config.set_up_logs
        config.output_level = :quiet
      end
    }

    it 'can be created' do
      OperationalEnumerator.create_transformer(wh_config).should_not be_nil
    end

    it 'uses the correct bcdatabase config' do
      OperationalEnumerator.bcdatabase[:name].should == 'ncs_navigator_core'
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
    let(:enumerator) {
      OperationalEnumerator.new(wh_config, :bcdatabase => bcdatabase_config)
    }
    let(:producer_names) { [] }
    let(:results) { enumerator.to_a(*producer_names) }

    describe 'for ListingUnit' do
      let(:producer_names) { [:listing_units] }
      let(:warehouse_model) { wh_config.model(:ListingUnit) }

      before do
        Factory(:listing_unit)
      end

      include_examples 'one to one'
    end

    describe 'for DwellingUnit' do
      let(:producer_names) { [:dwelling_units] }
      let(:warehouse_model) { wh_config.model(:DwellingUnit) }

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
      let(:warehouse_model) { wh_config.model(:LinkHouseholdDwelling) }

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
      let(:warehouse_model) { wh_config.model(:HouseholdUnit) }
      let(:core_model) { HouseholdUnit }

      before do
        Factory(:household_unit)
      end

      include_examples 'one to one'

      describe 'with manually determined variables' do
        include_context 'mapping test'

        [
          [:hh_eligibility_code,                3, :hh_elig,         '3'],
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
      let(:warehouse_model) { wh_config.model(:LinkPersonHousehold) }

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
          [:marital_status_code,                  2,     :maristat,     '2'],
          [:marital_status_other,           'On fire',   :maristat_oth],
          [:language_code,                        4,     :person_lang,  '4'],
          [:language_other,                 'Esperanto', :person_lang_oth],
          [:preferred_contact_method_code,        1,     :pref_contact, '1'],
          [:preferred_contact_method_other, 'Pigeon',    :pref_contact_oth],
          [:planned_move_code,                    1,     :plan_move,    '1'],
        ].each do |core_field, core_value, wh_field, wh_value|
          verify_mapping(core_field, core_value, wh_field, wh_value)
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
        Factory(:person_race, :person => Person.first, :race_code => 2)

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
          [:pid_age_eligibility_code, 3, :pid_age_elig, '3']
        ].each do |core_field, core_value, wh_field, wh_value|
          it "maps #{core_field} to #{wh_field}" do
            verify_mapping(core_field, core_value, wh_field, wh_value)
          end
        end
      end
    end

    describe 'for ParticipantConsent' do
      let(:producer_names) { [:participant_consents] }
      let!(:core_record) { Factory(:participant_consent, :person_who_consented => consenter) }
      let(:consenter) { Factory(:person, :first_name => 'Ginger') }
      let(:some_guy) { Factory(:person) }

      it 'generates one consent per source record' do
        results.collect(&:class).should == [wh_config.model(:ParticipantConsent)]
      end

      it "uses the participant's public ID" do
        results.first.p_id.should == Participant.first.p_id
      end

      it "uses the person consenting's public ID" do
        results.first.person_who_consented_id.should == consenter.person_id
      end

      it "uses the person withdrawing consent's public ID" do
        core_record.person_wthdrw_consent = some_guy
        core_record.save!

        results.first.person_wthdrw_consent_id.should == some_guy.person_id
      end

      it 'uses the public ID for the contact' do
        results.first.contact_id.should == Contact.first.contact_id
      end
    end

    describe 'for ParticipantConsentSample' do
      before do
        pcs = [Factory(:participant_consent_sample), Factory(:participant_consent_sample)]
        producer_names << :participant_consent_samples
        pcs.sort_by!{|a| a.participant_consent_sample_id}
        results.sort_by!{|a| a.participant_consent_sample_id}
        @paired = results.zip pcs
      end

      it 'generates one per source record' do
        results.collect(&:class).should == [wh_config.model(:ParticipantConsentSample)]*2
      end

      it "uses the participant's public ID" do
        @paired.each do |(result,pcs)|
          result.p_id.should == pcs.participant_consent.participant.p_id
        end
      end

      it "uses the participant consent's public ID" do
        @paired.each do |(result,pcs)|
          result.participant_consent_id.should == pcs.participant_consent.participant_consent_id
        end
      end
    end

    describe 'for ParticipantAuthorizationForm' do
      let(:producer_names) { [:participant_authorization_forms] }

      before do
        Factory(:participant_authorization_form)
      end

      it 'generates one per source record' do
        results.collect(&:class).should == [wh_config.model(:ParticipantAuth)]
      end

      it 'uses the public ID for participant' do
        results.first.p_id.should == Participant.first.p_id
      end

      it 'uses the public ID for contact' do
        results.first.contact_id.should == Contact.first.contact_id
      end

      it 'uses the public ID for provider' do
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
        results.collect(&:class).should == [wh_config.model(:ParticipantVisConsent)]
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
      let(:core_model) { ParticipantVisitRecord }

      before do
        Factory(:participant_visit_record, :rvis_person => visited)
      end

      it 'generates one per source record' do
        results.collect(&:class).should == [wh_config.model(:ParticipantRvis)]
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

      describe 'with manually determined variables' do
        include_context 'mapping test'

        [
          [:time_stamp_1, Time.local(2525, 12, 25, 11, 22, 33), :time_stamp_1, '2525-12-25T11:22:33'],
          [:time_stamp_2, Time.local(2525, 12, 25, 1, 2, 3), :time_stamp_2, '2525-12-25T01:02:03']
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for PpgDetail' do
      let(:producer_names) { [:ppg_details] }
      let(:warehouse_model) { wh_config.model(:PpgDetails) }

      let!(:ppg_detail) { Factory(:ppg_detail) }

      include_examples 'one to one'

      it 'uses the public ID for the participant' do
        results.first.p_id.should == Participant.first.p_id
      end
    end

    describe 'for PpgStatusHistory' do
      let(:producer_names) { [:ppg_status_histories] }
      let(:warehouse_model) { wh_config.model(:PpgStatusHistory) }

      let!(:ppg_status_history) { Factory(:ppg_status_history) }

      include_examples 'one to one'

      it 'uses the public ID for the participant' do
        results.first.p_id.should == Participant.first.p_id
      end
    end

    describe 'for Address' do
      let(:producer_names) { [:addresses] }
      let(:warehouse_model) { wh_config.model(:Address) }
      let(:core_model) { Address }
      let!(:address) { Factory(:address) }
      let(:provider) { Factory(:provider) }
      let(:institution) { Factory(:institution) }

      include_examples 'one to one'

      it 'uses the public ID for the person' do
        results.first.person_id.should == Person.first.person_id
      end

      # TODO: person_id and du_id should be mutually exclusive
      it 'uses the public ID for the DU' do
        results.first.du_id.should == DwellingUnit.first.du_id
      end

      it 'uses the public ID for the provider' do
        address.provider = provider
        address.save!

        results.first.provider_id.should == provider.provider_id
      end

      it 'uses the public ID for the institute' do
        address.institute = institution
        address.save!

        results.first.institute_id.should == institution.institute_id
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
      let(:warehouse_model) { wh_config.model(:Email) }
      let!(:email) { Factory(:email) }
      let(:provider) { Factory(:provider) }
      let(:institution) { Factory(:institution) }

      include_examples 'one to one'

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.person_id
      end

      it 'uses the public ID for the provider' do
        email.provider = provider
        email.save!

        results.first.provider_id.should == provider.provider_id
      end

      it 'uses the public ID for the institute' do
        email.institute = institution
        email.save!

        results.first.institute_id.should == institution.institute_id
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
      let(:warehouse_model) { wh_config.model(:Telephone) }
      let!(:telephone) { Factory(:telephone) }
      let(:provider) { Factory(:provider) }
      let(:institution) { Factory(:institution) }

      include_examples 'one to one'

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.person_id
      end

      it 'uses the public ID for the provider' do
        telephone.provider = provider
        telephone.save!

        results.first.provider_id.should == provider.provider_id
      end

      it 'uses the public ID for the institute' do
        telephone.institute = institution
        telephone.save!

        results.first.institute_id.should == institution.institute_id
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
      let(:warehouse_model) { wh_config.model(:Instrument) }
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
          [:instrument_breakoff_code,    2,              :ins_breakoff,   '2'],
          [:instrument_status_code,      4,              :ins_status,     '4'],
          [:instrument_mode_code,        2,              :ins_mode,       '2'],
          [:instrument_mode_other, 'Helicopter drop',    :ins_mode_oth],
          [:instrument_method_code,      1,              :ins_method,     '1'],
          [:instrument_comment,    'Confused',           :instru_comment],
          [:supervisor_review_code,      1,              :sup_review,     '1']
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for Event' do
      let(:producer_names) { [:events] }
      let(:warehouse_model) { wh_config.model(:Event) }
      let(:core_model) { Event }

      let!(:event) { Factory(:mdes_min_event, :participant => Factory(:participant)) }

      include_examples 'one to one'

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:event_disposition_category_code,  4,                  :event_disp_cat,    '4'],
          [:event_incentive_cash,       BigDecimal.new('7.11'),   :event_incent_cash, '7.11'],
          [:event_incentive_noncash,    'Chick-fil-a coupons',    :event_incent_noncash]
        ].each { |crit| verify_mapping(*crit) }
      end

      it 'uses the public ID for participant' do
        results.first.participant_id.should == Participant.first.p_id
      end

      describe 'with no disposition' do
        before do
          event.event_disposition = nil
          event.save!
        end

        it 'emits event when there is associated contact link' do
          # This rigamarole is because you apparently can't stop
          # FactoryGirl from initializing associations, even if you
          # provide an override.
          ContactLink.create!(
            :psu_code => 20000030, :event => event, :contact => Factory(:contact), :staff_id => 'dc')
          results.size.should == 1
        end

        it 'emits event when there is associated instrument' do
          Factory(:instrument, :event => event)
          results.size.should == 1
        end

        it 'emits nothing when there is no associated contact link and no associated instrument' do
          results.should == []
        end
      end

      describe 'with no associated contact link' do
        it 'emits event when there is disposition' do
          results.size.should == 1
        end

        describe 'and with no disposition' do
          before do
            event.event_disposition = nil
            event.save!
          end

          it 'emits event when there is associated instrument' do
            Factory(:instrument, :event => event)
            results.size.should == 1
          end

          it 'emits nothing when there is no associated instrument' do
            results.should == []
          end
        end
      end

      describe 'with no associated instrument' do
        it 'emits event when there is disposition' do
          results.size.should == 1
        end

        describe 'and with no disposition' do
          before do
            event.event_disposition = nil
            event.save!
          end

          it 'emits event when there is associated contact link' do
            ContactLink.create!(
              :psu_code => 20000030, :event => event, :contact => Factory(:contact), :staff_id => 'dc')
            results.size.should == 1
          end

          it 'emits nothing when there is no associated contact link' do
            results.should == []
          end
        end
      end

      describe '#event_disp' do
        describe 'for a pending event' do
          before do
            event.event_end_date = nil
          end

          it 'enumerates an interim code when the core code is interim' do
            event.event_disposition = 16
            event.save!

            results.first.event_disp.should == 16
          end

          it 'enumerates an interim code when the core code is final (legacy)' do
            event.event_disposition = 516
            event.save!

            results.first.event_disp.should == 16
          end
        end

        describe 'for a completed event' do
          before do
            event.event_end_date = Time.now - 3
          end

          it 'uses a final code when the core code is interim' do
            event.event_disposition = 18
            event.save!

            results.first.event_disp.should == 518
          end

          it 'uses a final code when the core code is final (legacy)' do
            event.event_disposition = 522
            event.save!

            results.first.event_disp.should == 522
          end
        end
      end
    end

    describe 'for Contact' do
      let(:producer_names) { [:contacts] }
      let(:warehouse_model) { wh_config.model(:Contact) }
      let(:core_model) { Contact }

      let!(:contact) { Factory(:contact) }

      include_examples 'one to one'

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:contact_disposition,    7,         :contact_disp, '507', 'always using a final code'],
          [:contact_disposition,    507,       :contact_disp, '507'],
          [:contact_language_code,        10,  :contact_lang, '10'],
          [:contact_language_other, 'Klingon', :contact_lang_oth],
          [:who_contacted_other,    'Cat',     :who_contact_oth]
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for ContactLink' do
      let(:producer_names) { [:contact_links] }
      let(:warehouse_model) { wh_config.model(:LinkContact) }
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
        results.first.provider_id.should == Provider.first.provider_id
      end
    end

    describe 'for NonInterviewReport' do
      let(:producer_names) { [:non_interview_reports] }
      let(:warehouse_model) { wh_config.model(:NonInterviewRpt) }
      let(:core_model) { NonInterviewReport }

      let!(:non_interview_report) { Factory(:non_interview_report) }

      include_examples 'one to one'

      it 'uses the public ID for contact' do
        results.first.contact_id.should == Contact.first.contact_id
      end

      it 'uses the public ID for dwelling unit' do
        results.first.du_id.should == DwellingUnit.first.du_id
      end

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.person_id
      end

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:nir_vacancy_information_code,         4,     :nir_vac_info, '4'],
          [:nir_vacancy_information_other,  'L',         :nir_vac_info_oth],
          [:nir_no_access_code,                   3,     :nir_noaccess, '3'],
          [:nir_no_access_other,            'B',         :nir_noaccess_oth],
          [:cog_disability_description,     'Small hat', :cog_dis_desc],
          [:permanent_disability_code,            2,     :perm_disability, '2'],
          [:deceased_inform_relation_other, 'Postman',   :deceased_inform_oth],
          [:year_of_death,                  '1865',      :yod],
          [:state_of_death_code,                  15,    :state_death, '15'],
          [:refusal_action_code,                  2,     :ref_action, '2'],
          [:long_term_illness_description,  'EB',        :lt_illness_desc],
          [:permanent_long_term_code,             -6,    :perm_ltr, '-6'],
          [:reason_unavailable_code,              4,     :reason_unavail, '4'],
          [:reason_unavailable_other,       'Bats',      :reason_unavail_oth],
          [:moved_inform_relation_other,    'Mr. Chips', :moved_relation_oth]
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for DwellingUnitTypeNonInterviewReport' do
      let(:producer_names) { [:dwelling_unit_type_non_interview_reports] }
      let(:warehouse_model) { wh_config.model(:NonInterviewRptDutype) }
      let(:core_model) { DwellingUnitTypeNonInterviewReport }

      let!(:non_interview_report) { Factory(:dwelling_unit_type_non_interview_report) }

      include_examples 'one to one'

      it 'uses the public ID for the non-interview report' do
        results.first.nir_id.should == NonInterviewReport.first.public_id
      end

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:nir_dwelling_unit_type_code,        1,     :nir_type_du, '1'],
          [:nir_dwelling_unit_type_other, 'Houseboat', :nir_type_du_oth]
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for NoAccessNonInterviewReport' do
      let(:producer_names) { [:no_access_non_interview_reports] }
      let(:warehouse_model) { wh_config.model(:NonInterviewRptNoaccess) }
      let(:core_model) { NoAccessNonInterviewReport }

      let!(:non_interview_report) { Factory(:no_access_non_interview_report) }

      include_examples 'one to one'

      it 'uses the public ID for the non-interview report' do
        results.first.nir_id.should == NonInterviewReport.first.public_id
      end

      it 'uses the MDES name for its own ID' do
        results.first.nir_noaccess_id.should == NoAccessNonInterviewReport.first.public_id
      end

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:nir_no_access_code,        -5, :nir_noaccess, '-5'],
          [:nir_no_access_other, 'Bats',   :nir_noaccess_oth]
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for RefusalNonInterviewReport' do
      let(:producer_names) { [:refusal_non_interview_reports] }
      let(:warehouse_model) { wh_config.model(:NonInterviewRptRefusal) }
      let(:core_model) { RefusalNonInterviewReport }

      let!(:non_interview_report) { Factory(:refusal_non_interview_report) }

      include_examples 'one to one'

      it 'uses the public ID for the non-interview report' do
        results.first.nir_id.should == NonInterviewReport.first.public_id
      end
    end

    describe 'for VacantNonInterviewReport' do
      let(:producer_names) { [:vacant_non_interview_reports] }
      let(:warehouse_model) { wh_config.model(:NonInterviewRptVacant) }
      let(:core_model) { VacantNonInterviewReport }

      let!(:non_interview_report) { Factory(:vacant_non_interview_report) }

      include_examples 'one to one'

      it 'uses the public ID for the non-interview report' do
        results.first.nir_id.should == NonInterviewReport.first.public_id
      end
    end

    describe 'for Institution' do
      let(:producer_names) { [:institutions] }
      let(:warehouse_model) { wh_config.model(:Institution) }
      let(:core_model) { Institution }

      before do
        Factory(:institution)
      end

      include_examples 'one to one'

      it 'uses the public ID for the institution' do
        results.first.institute_id.should == Institution.first.public_id
      end

    end

    describe 'for InstitutionPersonLink' do
      let(:producer_names) { [:institution_person_links] }
      let(:warehouse_model) { wh_config.model(:LinkPersonInstitute) }

      before do
        Factory(:institution_person_link)
      end

      include_examples 'one to one'

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.public_id
      end

      it 'uses the public ID for institution' do
        results.first.institute_id.should == Institution.first.public_id
      end
    end

    describe 'for Provider' do
      let(:producer_names) { [:providers] }
      let(:warehouse_model) { wh_config.model(:Provider) }
      let(:core_model) { Provider }

      before do
        Factory(:provider)
      end

      include_examples 'one to one'

      it 'uses the public ID for the provider' do
        results.first.provider_id.should == Provider.first.public_id
      end

    end

    describe 'for PersonProviderLink' do
      let(:producer_names) { [:person_provider_links] }
      let(:warehouse_model) { wh_config.model(:LinkPersonProvider) }
      let(:core_model) { PersonProviderLink }

      before do
        Factory(:person_provider_link)
      end

      include_examples 'one to one'

      it 'uses the public ID for person' do
        results.first.person_id.should == Person.first.public_id
      end

      it 'uses the public ID for provider' do
        results.first.provider_id.should == Provider.first.public_id
      end

      describe 'with manually mapped variables' do
        include_context 'mapping test'

        [
          [:provider_intro_outcome_code,        -5, :prov_intro_outcome, '-5'],
          [:provider_intro_outcome_other,      'X', :prov_intro_outcome_oth],
        ].each { |crit| verify_mapping(*crit) }
      end
    end

    describe 'for ProviderRole' do
      let(:producer_names) { [:provider_roles] }
      let(:warehouse_model) { wh_config.model(:ProviderRole) }

      before do
        Factory(:provider_role)
      end

      include_examples 'one to one'

      it 'generates one per source record' do
        results.collect(&:class).should == [wh_config.model(:ProviderRole)]
      end

      it 'uses the public ID for provider_role' do
        results.first.provider_role_id.should == ProviderRole.first.public_id
      end

      it 'uses the public ID for provider' do
        results.first.provider_id.should == Provider.first.public_id
      end
    end

    describe 'ordering' do
      let(:order) { OperationalEnumerator.record_producers.collect(&:name) }

      OperationalEnumerator.record_producers.each do |rp|
        it "places :#{rp.name} after all its dependencies" do
          joined_tables = rp.query.scan(/JOIN (\w+)/).collect(&:first)
          predecessors = order[0, order.index(rp.name)].collect(&:to_s)
          joined_tables.reject { |t| predecessors.include?(t) }.should == []
        end
      end
    end

    describe "a producer's metadata" do
      let(:producer) {
        OperationalEnumerator.record_producers.find { |rp| rp.name == :participants }
      }
      let(:column_map) { producer.column_map(Participant.attribute_names, wh_config) }

      it 'includes the MDES model' do
        producer.model(wh_config).should == wh_config.model(:Participant)
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
