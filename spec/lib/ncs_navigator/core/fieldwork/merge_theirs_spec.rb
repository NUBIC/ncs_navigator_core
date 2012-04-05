require 'spec_helper'

module NcsNavigator::Core::Fieldwork
  describe MergeTheirs do
    subject do
      Class.new do
        include MergeTheirs

        attr_accessor :contacts
        attr_accessor :events
        attr_accessor :instruments
        attr_accessor :response_sets
        attr_accessor :responses

        def initialize
          self.contacts = {}
          self.events = {}
          self.instruments = {}
          self.response_sets = {}
          self.responses = {}
        end
      end.new
    end

    def merge
      subject.merge
    end

    let(:logdev) { StringIO.new }
    let(:logger) { ::Logger.new(logdev) }
    let(:log) { logdev.string }

    before do
      subject.logger = logger
    end

    shared_examples_for 'a date parser' do |attrs|
      from = attrs[:from]
      to = attrs[:to]

      it "copies P.#{from} -> C.#{to}" do
        merge

        current.send(to).should == Date.parse(proposed[from])
      end

      it "sets C.#{to} nil if P.#{from} is null" do
        proposed[from] = nil

        merge

        current.send(to).should be_nil
      end

      it 'logs an error if C does not exist' do
        set['an_id'][:current] = nil

        merge

        log.should =~ /unable to find .+ an_id/i
      end

      it 'logs an error if P.contact_date is unparseable' do
        proposed[from] = 'garbage'

        merge

        log.should =~ /parsing date "garbage" raised an error/i
      end
    end

    describe 'given proposal P and current C' do
      describe 'on contacts' do
        let(:current) { Factory(:contact) }
        let(:set) { subject.contacts }
        let(:proposed) do
          {
            'contact_date' => '2012-03-01',
            'start_time' => '12:34',
            'end_time' => '13:45',
            'disposition' => 1
          }
        end

        before do
          subject.contacts = {
            'an_id' => {
              :current => current,
              :proposed => proposed
            }
          }
        end

        it_should_behave_like 'a date parser', :from => 'contact_date', :to => 'contact_date_date'

        it 'copies P.start_time -> C.start_time' do
          merge

          current.contact_start_time.should == proposed['start_time']
        end

        it 'copies P.end_time -> C.end_time' do
          merge

          current.contact_end_time.should == proposed['end_time']
        end

        it 'copies P.contact_disposition -> C.contact_disposition' do
          merge

          current.contact_disposition.should == proposed['disposition']
        end
      end

      describe 'on events' do
        let(:current) { Factory(:event) }
        let(:set) { subject.events }
        let(:proposed) do
          {
            'start_time' => '12:34',
            'end_time' => '17:52',
            'start_date' => '2012-03-01',
            'end_date' => '2012-03-16',
            'disposition' => 1,
            'disposition_category' => 1
          }
        end

        before do
          subject.events = {
            'an_id' => {
              :current => current,
              :proposed => proposed
            }
          }
        end

        it 'copies P.start_time -> C.start_time' do
          merge

          current.event_start_time.should == proposed['start_time']
        end

        it 'copies P.end_time -> C.end_time' do
          merge

          current.event_end_time.should == proposed['end_time']
        end

        it 'copies P.disposition -> C.event_disposition' do
          merge

          current.event_disposition.should == proposed['disposition']
        end

        it 'copies P.disposition_category -> C.event_disposition_category_code' do
          merge

          current.event_disposition_category_code.should == proposed['disposition_category']
        end

        it 'does not set C.event_disposition_category_code to nil' do
          proposed['disposition_category'] = nil

          merge

          current.event_disposition_category_code.should_not be_nil
        end

        it_should_behave_like 'a date parser', :from => 'start_date', :to => 'event_start_date'
        it_should_behave_like 'a date parser', :from => 'end_date', :to => 'event_end_date'
      end

      describe 'on response sets' do
        let!(:instrument) { Factory(:instrument, :instrument_id => 'instrument_id') }
        let!(:current) { Factory(:response_set, :api_id => 'an_id') }
        let!(:survey) { Factory(:survey, :api_id => 'survey_id') }

        before do
          subject.instruments = {
            'an_id' => {
              :current => instrument,
              :proposed => {
                'instrument_id' => instrument.instrument_id,
                'response_set' => {
                  'uuid' => 'an_id',
                  'survey_id' => 'survey_id'
                }
              }
            }
          }

          subject.response_sets = {
            'an_id' => {
              :current => current,
              :proposed => subject.instruments['an_id'][:proposed]['response_set']
            }
          }
        end

        describe 'if C is nil' do
          before do
            subject.response_sets['an_id'][:current] = nil
          end

          it 'creates a new response set' do
            merge

            subject.response_sets['an_id'][:current].should be_new_record
          end

          it 'associates the response set with its instrument' do
            merge

            subject.response_sets['an_id'][:current].instrument.should == instrument
          end

          it 'associates the response set with its survey' do
            merge

            subject.response_sets['an_id'][:current].survey.should == survey
          end
        end
      end

      describe 'on responses' do
        let!(:q) { Factory(:question, :api_id => 'question_id') }
        let!(:a) { Factory(:answer, :api_id => 'answer_id') }
        let!(:old_q) { Factory(:question) }
        let!(:old_a) { Factory(:answer) }
        let!(:current) { Factory(:response, :api_id => 'an_id', :question => old_q, :answer => old_a) }
        let!(:response_set) { Factory(:response_set) }

        before do
          subject.response_sets = {
            response_set.api_id => {
              :current => response_set,
              :proposed => {
                'uuid' => response_set.api_id,
                'responses' => [
                  {
                    'answer_id' => 'answer_id',
                    'created_at' => '2012-02-09T10:55:17-06:00',
                    'modified_at' => '2012-04-05T00:20:55-05:00',
                    'question_id' => 'question_id',
                    'uuid' => 'an_id'
                  }
                ]
              }
            }
          }

          subject.responses = {
            'an_id' => {
              :current => current,
              :proposed => subject.response_sets[response_set.api_id][:proposed]['responses'][0]
            }
          }
        end

        shared_examples_for 'a response copier' do
          let(:current_response) { subject.responses['an_id'][:current] }
          let(:proposed_response) { subject.responses['an_id'][:proposed] }

          it 'copies P.answer_id -> C.answer_id' do
            merge

            current_response.answer.should == a
          end

          it 'copies P.question_id -> C.question_id' do
            merge

            current_response.question.should == q
          end

          describe 'if P.unit exists' do
            before do
              proposed_response['unit'] = 'mL'
            end

            it 'copies P.unit -> C.unit' do
              merge

              current_response.unit.should == proposed_response['unit']
            end
          end

          describe 'if P.value is an integer' do
            before do
              proposed_response['value'] = 10
            end

            it 'copies P.value -> C.integer_value' do
              merge

              current_response.integer_value.should == proposed_response['value']
            end
          end

          describe 'if P.value is a floating-point value' do
            before do
              proposed_response['value'] = 10.74
            end

            it 'copies P.value -> C.float_value' do
              merge

              current_response.float_value.should == proposed_response['value']
            end
          end

          describe 'if P.value is parseable as a datetime' do
            before do
              proposed_response['value'] = '2001-01-01T12:00:00Z'
            end

            it 'copies P.value -> C.datetime_value' do
              merge

              current_response.datetime_value.should == Time.parse(proposed_response['value'])
            end
          end

          describe 'if P.value is null' do
            it 'nulls out all values' do
              merge

              current_response.datetime_value.should be_nil
              current_response.float_value.should be_nil
              current_response.integer_value.should be_nil
              current_response.string_value.should be_nil
              current_response.text_value.should be_nil
            end
          end

          describe 'if the value is greater than 255 characters' do
            before do
              proposed_response['value'] = 'a' * 256
            end

            it 'copies P.value -> C.text_value' do
              merge

              current_response.text_value.should == proposed_response['value']
            end
          end

          describe 'the default value action' do
            before do
              proposed_response['value'] = 'abc'
            end

            it 'copies P.value -> C.string_value' do
              merge

              current_response.string_value.should == proposed_response['value']
            end
          end
        end

        describe 'if C is not nil' do
          it_should_behave_like 'a response copier'
        end

        describe 'if C is nil' do
          before do
            subject.responses['an_id'][:current] = nil
          end

          it 'builds a new response' do
            merge

            subject.responses['an_id'][:current].should be_new_record
          end

          it 'associates the response with its response set' do
            merge

            subject.responses['an_id'][:current].response_set.should == response_set
          end

          it_should_behave_like 'a response copier'
        end
      end
    end
  end
end
