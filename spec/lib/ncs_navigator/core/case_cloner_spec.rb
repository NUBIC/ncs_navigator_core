require 'spec_helper'

module NcsNavigator::Core
  describe CaseCloner do
    let(:cloner) { CaseCloner.new(mother.p_id) }

    let!(:earlier_person) { Factory(:person) }

    let!(:mother) { FactoryGirl.create(:participant, :with_self, :p_type_code => 3) }
    let!(:child1) { FactoryGirl.create(:participant, :with_self, :p_type_code => 6) }
    let!(:child2) { FactoryGirl.create(:participant, :with_self, :p_type_code => 6) }

    def link_mother_child(mother, child)
      Factory(:participant_person_link,
        :participant => mother, :person => child.person, :relationship_code => 8)
      Factory(:participant_person_link,
        :participant => child, :person => mother.person, :relationship_code => 2)
    end

    before do
      link_mother_child(mother, child1)
      link_mother_child(mother, child2)
    end

    describe '#source_participants' do
      let(:actual) { cloner.source_participants }

      it 'includes the referenced participant' do
        actual.should include(mother)
      end

      it 'includes all associated children' do
        actual.should include(child1)
        actual.should include(child2)
      end

      it 'includes each participant exactly once' do
        actual.size.should == 3
      end
    end

    describe '#clone_cases_side' do
      let(:clone_result) { cloner.clone_cases_side }
      let(:mother_clone) { clone_result[mother] }

      it 'returns a mapping from the source participants to the cloned participants' do
        clone_result.should respond_to(:[])
        clone_result.keys.map(&:class).uniq.should == [Participant]
        clone_result.values.map(&:class).uniq.should == [Participant]
      end

      it 'persists the cloned records' do
        clone_result.each { |_, result| Participant.where(:id => result.id).count.should == 1 }
      end

      shared_examples 'clone verification' do
        it 'has a different internal ID in the clone' do
          in_clone.id.should_not == in_source.id
        end

        it 'has an internal ID in the clone' do
          in_clone.id.should_not be_nil
        end

        it 'is the same type in the clone' do
          in_clone.class.should == in_source.class
        end

        it 'has a different public ID in the clone (if applicable)' do
          pending "no public ID for #{in_source.class}" unless in_source.respond_to?(:public_id)

          in_clone.public_id.should_not == in_source.public_id
        end

        it 'has some public ID in the clone (if applicable)' do
          pending "no public ID for #{in_source.class}" unless in_source.respond_to?(:public_id)

          in_clone.public_id.should_not be_nil
        end

        it 'has a different access code in the clone (if applicable)' do
          pending "no access_code for #{in_source.class}" unless in_source.respond_to?(:access_code)

          in_clone.access_code.should_not == in_source.access_code
        end

        it 'has a some access code in the clone (if applicable)' do
          pending "no access_code for #{in_source.class}" unless in_source.respond_to?(:access_code)

          in_clone.access_code.should_not be_nil
        end

        def some_attribute(instance)
          instance.attributes.
            select { |name, value| value && [/id\z/, /\A(created|updated)_at\z/, /access_code/, /lock_version/].none? { |re| re =~ name } }.
            sort_by { |name, _| name =~ /_code\z/ ? 1 : 0 }.
            first or pending "No scalar attributes for #{instance.class}"
        end

        it 'copies scalar attributes to the clone' do
          attribute, source_value = some_attribute(in_source)
          source_value.should == in_clone.send(attribute)
        end

        it 'does not copy created_at to the clone' do
          in_source # prompt to create
          sleep 1
          in_clone.created_at.should_not == in_source.created_at
        end

        it 'does not copy updated_at to the clone' do
          in_source # prompt to create
          sleep 1
          in_clone.updated_at.should_not == in_source.updated_at
        end

        it 'does not copy versions to the clone' do
          in_clone.versions.should == []
        end
      end

      describe 'for mother participant' do
        let(:in_source) { mother }
        let(:in_clone) { mother_clone }

        include_examples 'clone verification'
      end

      describe 'for child1 participant' do
        let(:in_source) { child1 }
        let(:in_clone) { clone_result[child1] }

        include_examples 'clone verification'
      end

      describe 'for child1 participant' do
        let(:in_source) { child2 }
        let(:in_clone) { clone_result[child2] }

        include_examples 'clone verification'
      end

      describe 'for related data' do
        let!(:threem_event) { Factory(:event, :participant => mother, :event_type_code => 23) }

        let!(:threem_contact_1) { Factory(:contact) }
        let!(:threem_contact_link_1) {
          Factory(:contact_link, :contact => threem_contact_1, :person => mother.person, :event => threem_event, :instrument => threem_interview)
        }

        let!(:threem_contact_2) { Factory(:contact) }
        let!(:threem_contact_link_2) {
          Factory(:contact_link, :contact => threem_contact_2, :person => mother.person, :event => threem_event, :instrument => threem_interview)
        }

        let!(:threem_interview) { Factory(:instrument) }

        let!(:threem_survey_mother) {
          load_survey_string(<<-SURV)
            survey '3M Mother' do
              section '1' do
                q_alpha 'How are things?'
                a_1 'Okay'
                a_2 'Fine'
              end
            end
          SURV
        }

        let!(:threem_survey_child) {
          load_survey_string(<<-SURV)
            survey '3M Child' do
              section '1' do
                q_beta 'And how is the baby?'
                a_1 'Cute'
                a_2 'Not cute'
              end
            end
          SURV
        }

        let!(:threem_mother_rs) {
          Factory(:response_set,
            :instrument => threem_interview, :survey => threem_survey_mother,
            :participant => mother, :person => mother.person
          )
        }
        let!(:threem_child1_rs)  {
          Factory(:response_set,
            :instrument => threem_interview, :survey => threem_survey_child,
            :participant => child1, :person => mother.person
          )
        }
        let!(:threem_child2_rs)  {
          Factory(:response_set,
            :instrument => threem_interview, :survey => threem_survey_child,
            :participant => child2, :person => mother.person
          )
        }

        let!(:child1_consent_event) { Factory(:event, :event_type_code => 10, :participant => child1) }
        let!(:mother_consent_event) { Factory(:event, :event_type_code => 10, :participant => mother) }

        let!(:child1_consent_cl) { Factory(:contact_link, :event => child1_consent_event, :contact => consent_contact) }
        let!(:mother_consent_cl) { Factory(:contact_link, :event => mother_consent_event, :contact => consent_contact) }
        let!(:child1_consent_during_threem) { Factory(:contact_link, :event => child1_consent_event, :contact => threem_contact_1) }

        let!(:consent_contact) {
          Factory(:contact)
        }

        let!(:consent) {
          Factory(:participant_consent, :participant => mother,
            :consent_form_type_code => 1, :contact => consent_contact)
        }

        let!(:sample_consent) {
          Factory(:participant_consent_sample, :participant_consent => consent)
        }

        before do
          Factory(:address, :person => mother.person)
          Factory(:email, :person => mother.person)
          Factory(:telephone, :person => mother.person)
          Factory(:person_race, :person => mother.person)
          Factory(:household_person_link, :person => mother.person)
          Factory(:institution_person_link, :person => mother.person)
          Factory(:person_provider_link, :person => mother.person)
          Factory(:sampled_persons_ineligibility, :person => mother.person)
          Factory(:ppg_detail, :participant => mother)
          Factory(:ppg_status_history, :participant => mother)

          mother_q = threem_survey_mother.questions.first
          threem_mother_rs.responses.create!(:question => mother_q, :answer => mother_q.answers.first, :unit => 'cm')
          child_q = threem_survey_child.questions.first
          threem_child1_rs.responses.create!(:question => child_q, :answer => child_q.answers.first, :unit => 'cm')
          threem_child2_rs.responses.create!(:question => child_q, :answer => child_q.answers.last, :unit => 'cm')
        end

        def self.response_sets_for_survey(survey_title)
          "response_sets.joins(:survey).where('surveys.title = ?', #{survey_title.inspect})"
        end

        [
          'self_link',
          'participant_person_links.where("relationship_code != 1").first',
          'participant_person_links.where("relationship_code != 1").first.person',
          'person',
          'person.addresses.first',
          'person.emails.first',
          'person.telephones.first',
          'person.contact_links.order(:contact_id).first',
          'person.contact_links.order(:contact_id).first.event',
          'person.contact_links.order(:contact_id).first.contact',
          'person.contact_links.order(:contact_id).first.instrument',
          "person.contact_links.order(:contact_id).first.instrument.#{response_sets_for_survey '3M Mother'}.first",
          "person.contact_links.order(:contact_id).first.instrument.#{response_sets_for_survey '3M Child'}.first",
          "person.contact_links.order(:contact_id).first.instrument.#{response_sets_for_survey '3M Mother'}.first.responses.first",
          "person.contact_links.order(:contact_id).first.instrument.#{response_sets_for_survey '3M Mother'}.first.responses.last",
          "person.contact_links.order(:contact_id).first.instrument.#{response_sets_for_survey '3M Mother'}.first.person",
          'person.races.first',
          'person.household_person_links.first',
          'person.household_person_links.first.household_unit',
          'person.participant_person_links.where("relationship_code != 1").first.participant',
          'person.participant_person_links.where("relationship_code =  1").first.participant',
          'person.institution_person_links.first',
          'person.person_provider_links.first',
          'person.sampled_persons_ineligibilities.first',
          'ppg_details.first',
          'ppg_status_histories.last',
          'participant_consents.first',
          'participant_consents.first.contact',
          'participant_consents.first.participant_consent_samples.first',
          'events.last',
          'events.where(:event_type_code => 23).first.contact_links.order(:contact_id).last',
          'events.where(:event_type_code => 23).first.contact_links.order(:contact_id).last.contact',
          'events.where(:event_type_code => 23).first.contact_links.order(:contact_id).last.instrument',
          "events.where(:event_type_code => 23).first.contact_links.order(:contact_id).last.instrument.#{response_sets_for_survey '3M Mother'}.first",
          "events.where(:event_type_code => 23).first.contact_links.order(:contact_id).last.instrument.#{response_sets_for_survey '3M Mother'}.first.responses.first",
          "events.where(:event_type_code => 23).first.contact_links.order(:contact_id).last.instrument.#{response_sets_for_survey '3M Mother'}.first.responses.last",
          'response_sets.first',
          'response_sets.first.responses.first'
        ].each do |exp|
          describe exp do
            let(:in_source) { mother.instance_eval(exp) }
            let(:in_clone)  { mother_clone.instance_eval(exp) }

            include_examples 'clone verification'
          end
        end

        %w(
          person.institution_person_links.first.institution
          person.person_provider_links.first.provider
          response_sets.first.survey
          response_sets.first.responses.first.question
          response_sets.first.responses.first.answer
        ).each do |exp|
          describe exp do
            let(:in_source) { mother.instance_eval(exp) }
            let(:in_clone)  { mother_clone.instance_eval(exp) }

            it 'is the same object' do
              in_clone.id.should == in_source.id
            end
          end
        end

        it 'reuses the same cloned object when there are multiple referencing paths' do
          participant_rs = mother_clone.response_sets.where(:survey_id => threem_survey_mother).first
          instrument_rs = mother_clone.events.where(:event_type_code => 23).first.
            contact_links.first.instrument.response_sets.where(:survey_id => threem_survey_mother).first

          participant_rs.id.should == instrument_rs.id
        end
      end
    end
  end
end
