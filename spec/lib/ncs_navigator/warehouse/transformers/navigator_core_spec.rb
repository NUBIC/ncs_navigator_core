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

    shared_context 'mapping test' do
      before do
        # ignore unused so we can see the mapping failures
        NavigatorCore.on_unused_columns :ignore
      end

      after do
        NavigatorCore.on_unused_columns :fail
      end

      def verify_mapping(core_field, core_value, wh_field, wh_value=nil)
        wh_value ||= core_value
        core_model.last.tap { |p| p.send("#{core_field}=", core_value) }.save!
        results.last.send(wh_field).should == wh_value
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
          it "maps #{core_field} to #{wh_field}" do
            verify_mapping(core_field, core_value, wh_field, wh_value)
          end
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
  end
end
