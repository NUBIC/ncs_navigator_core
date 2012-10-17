require 'spec_helper'

require File.expand_path('../scheduled_activity_contexts', __FILE__)

module Psc
  ##
  # These tests rely quite heavily on values present in the test fixtures.  It
  # is RECOMMENDED that you keep scheduled_activity_contexts open in a split
  # pane while reading these examples.
  describe ScheduledActivity do
    I = ScheduledActivity::Implications

    let(:empty_sa) { ScheduledActivity.new }

    def self.it_maps(mapping)
      from, to = mapping.to_a.first

      it "maps #{from} to #{to}" do
        source = from.split('.').inject(row) { |r, a| r[a] }
        target = sa.send(to)

        target.should == source
      end
    end

    describe '.from_report' do
      include_context 'from report'

      it_maps 'activity_name' => 'activity_name'
      it_maps 'activity_status' => 'current_state'
      it_maps 'activity_type' => 'activity_type'
      it_maps 'grid_id' => 'activity_id'
      it_maps 'ideal_date' => 'ideal_date'
      it_maps 'labels' => 'labels'
      it_maps 'scheduled_date' => 'activity_date'
      it_maps 'subject.person_id' => 'person_id'

      it 'handles empty hashes' do
        ScheduledActivity.from_report({}).should be_instance_of(ScheduledActivity)
      end
    end

    describe '.from_schedule' do
      include_context 'from schedule'

      it_maps 'activity.name' => 'activity_name'
      it_maps 'activity.type' => 'activity_type'
      it_maps 'assignment.id' => 'person_id'
      it_maps 'current_state.date' => 'activity_date'
      it_maps 'current_state.name' => 'current_state'
      it_maps 'ideal_date' => 'ideal_date'
      it_maps 'labels' => 'labels'
      it_maps 'study_segment' => 'study_segment'

      it 'handles empty hashes' do
        ScheduledActivity.from_schedule({}).should be_instance_of(ScheduledActivity)
      end
    end

    shared_examples_for 'a label reader' do
      def self.it_reads_label(prefix, expected)
        describe "#{prefix}_label" do
          it "returns the first label with prefix #{prefix}:" do
            sa.send("#{prefix}_label").should == expected
          end

          it 'returns nil if there is no matching label' do
            empty_sa.send("#{prefix}_label").should be_nil
          end
        end
      end

      it_reads_label 'collection',        'biological'
      it_reads_label 'event',             'birth'
      it_reads_label 'instrument',        'ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
      it_reads_label 'order',             '01_02'
      it_reads_label 'participant_type',  'child'
      it_reads_label 'references',        'ins_que_birth_int_ehpbhi_p2_v2.0'
    end

    shared_examples_for 'an activity state reader' do
      describe '#open?' do
        it 'returns true for scheduled activities' do
          sa.should be_open
        end

        it 'returns true for conditional activities' do
          sa.current_state = ScheduledActivity::CONDITIONAL

          sa.should be_open
        end

        it 'returns false if the state is blank' do
          sa.current_state = nil

          sa.should_not be_open
        end

        it 'returns false for canceled activities' do
          sa.current_state = ScheduledActivity::CANCELED

          sa.should_not be_open
        end

        it 'returns false for missed activities' do
          sa.current_state = ScheduledActivity::MISSED

          sa.should_not be_open
        end

        it 'returns false for occurred activities' do
          sa.current_state = ScheduledActivity::OCCURRED

          sa.should_not be_open
        end

        it 'returns false for activities marked N/A' do
          sa.current_state = ScheduledActivity::NA

          sa.should_not be_open
        end
      end

      describe '#closed?' do
        it 'returns !#open?' do
          sa.stub!(:open? => false)

          sa.should be_closed
        end

        it 'returns false if the state is blank' do
          sa.current_state = nil

          sa.should_not be_closed
        end
      end

      describe '#scheduled?' do
        it 'returns true for scheduled activities' do
          sa.should be_scheduled
        end

        it 'returns false for canceled activities' do
          canceled_sa.should_not be_scheduled
        end

        it 'returns false if there is no activity state' do
          empty_sa.should_not be_scheduled
        end
      end

      describe '#canceled?' do
        it 'returns true for canceled activities' do
          canceled_sa.should be_canceled
        end

        it 'returns false for scheduled activities' do
          sa.should_not be_canceled
        end

        it 'returns false if there is no activity state' do
          empty_sa.should_not be_canceled
        end
      end
    end

    shared_examples_for 'an entity deriver' do
      it 'derives a person' do
        sa.derive_implied_entities

        sa.person.should == I::Person.new(sa.person_id)
      end

      it 'derives a contact' do
        sa.derive_implied_entities

        sa.contact.should == I::Contact.new(sa.activity_date, sa.person)
      end

      it 'derives an event' do
        sa.derive_implied_entities

        sa.event.should == I::Event.new(sa.event_label,
                                        sa.ideal_date,
                                        sa.contact,
                                        sa.person)
      end

      describe 'if the activity does not have a references label' do
        before do
          sa.labels = 'event:foo instrument:1.0:baz'

          sa.derive_implied_entities
        end

        it 'derives an instrument' do
          sa.instrument.should == I::Instrument.new(sa.survey,
                                                    sa.referenced_survey,
                                                    sa.activity_name,
                                                    sa.event,
                                                    sa.person)

        end
      end

      describe 'if the activity does not have an event label' do
        before do
          sa.labels = 'instrument:1.0:foo'

          sa.derive_implied_entities
        end

        it 'does not derive an instrument' do
          sa.instrument.should be_nil
        end
      end

      describe 'if the activity has a references label' do
        before do
          sa.labels = 'event:foo references:bar instrument:1.0:baz'

          sa.derive_implied_entities
        end

        it 'does not derive an instrument' do
          sa.instrument.should be_nil
        end
      end

      it 'derives a survey' do
        sa.derive_implied_entities

        sa.survey.should == I::Survey.new(sa.instrument_label, sa.participant_type_label, sa.order_label)
      end

      it 'derives a referenced survey' do
        sa.derive_implied_entities

        sa.referenced_survey.should == I::SurveyReference.new(sa.references_label)
      end

      it 'derives a contact link' do
        sa.derive_implied_entities

        sa.contact_link.should == I::ContactLink.new(sa.person,
                                                     sa.contact,
                                                     sa.event,
                                                     sa.instrument)
      end
    end

    describe 'with a report row' do
      include_context 'from report'

      it_should_behave_like 'a label reader'
      it_should_behave_like 'an activity state reader'
      it_should_behave_like 'an entity deriver'
    end

    describe 'with a schedule row' do
      include_context 'from schedule'

      it_should_behave_like 'a label reader'
      it_should_behave_like 'an activity state reader'
      it_should_behave_like 'an entity deriver'
    end

    let(:sa) { ScheduledActivity.new }

    describe '.new' do
      it 'accepts keyword arguments' do
        sa = ScheduledActivity.new(:activity_id => 'foo')

        sa.activity_id.should == 'foo'
      end
    end

    describe '#name' do
      it 'returns #activity_name' do
        sa.activity_name = 'foo'

        sa.name.should == 'foo'
      end
    end

    describe '#id' do
      it 'returns #activity_id' do
        sa.activity_id = 'foo'

        sa.id.should == 'foo'
      end
    end
  end
end
