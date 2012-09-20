# -*- coding: utf-8 -*-
require 'erb'
require 'facets/random'
require 'ostruct'

def link_participant_to_associated_entities
  @p.person = @person
  @p.events << @event

  @p.save!
end

# We want direct Rack::Test access, but it's not really an API-only
# integration test.
Before '@merge' do
  def browser
    Capybara.current_session.driver.browser
  end

  class << self
    extend Forwardable

    def_delegators :browser, *Rack::Test::Methods::METHODS
  end

  # We're not concerned with the Cases -> PSC sync for most merge scenarios, so
  # just make it always succeed.  Scenarios that do care about that can fix
  # this up.
  Merge.psc_sync_strategy = Class.new(OpenStruct) do
    def run
      true
    end
  end
end

Given /^the participant$/ do |table|
  person_attrs, p_attrs = table.raw.partition { |k, v| k =~ /^person/ }
  person_attrs.map! { |k, v| [k.sub('person/', ''), v] }

  @person = Person.create!(Hash[*person_attrs.flatten])
  @p = Participant.create!(Hash[*p_attrs.flatten])
end

Given /^the event$/ do |table|
  data = table.rows_hash
  type_name = data.delete('event_type')

  code = NcsCode.for_list_name_and_display_text('EVENT_TYPE_CL1', type_name)
  raise "Unknown event type #{type_name}" unless code

  @event = Event.create!(data.merge(:event_type => code,
                                    :event_start_date => data['event_start_date']))
end

Given /^the survey$/ do |table|
  data = table.rows_hash

  str = %Q{
survey '#{data['title']}' do
  section 'Questions' do
    q 'Question 1'
    a_1 :string
    q 'Question 2'
    a_1 :string
    q 'Question 3'
    a_1 :string
  end
end
  }

  Surveyor::Parser.new.parse(str)
end

Given /^I complete the fieldwork set$/ do |table|
  link_participant_to_associated_entities

  data = table.rows_hash

  fixtures_root = File.expand_path('../../fixtures', __FILE__)
  data_file = File.expand_path(data.delete('with'), fixtures_root)

  steps %Q{
    When I POST /api/v1/fieldwork.json with
      | start_date            | end_date            | client_id            |
      | #{data['start_date']} | #{data['end_date']} | #{data['client_id']} |
    Then the response status is 200
  }

  context = {
    'contact_id' => Contact.last.public_id,
    'instrument_id' => Instrument.last.public_id,
    'person_id' => Person.last.public_id,
    'response_set_id' => ResponseSet.last.api_id,
    'survey_id' => Survey.last.api_id,
    'question_ids' => Question.all.map(&:api_id),
    'answer_ids' => Answer.all.map(&:api_id)
  }

  fieldwork_data = ERB.new(File.read(data_file)).result(binding)

  uri = last_response.headers['Location']
  put uri, fieldwork_data
end

When /^the merge runs$/ do
  ok = NcsNavigator::Core::Fieldwork::MergeWorker.jobs.all? do |job|
    job['class'].constantize.new.perform(*job['args'])
  end

  ok.should be_true
end
