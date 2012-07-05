# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'fieldwork/show' do
  let(:fieldwork) { Fieldwork.new }

  before do
    assign(:fieldwork, fieldwork)
  end

  it 'shows Fieldwork#fieldwork_id' do
    fieldwork.fieldwork_id = 'the_id'

    render

    rendered.should have_selector('.fieldwork_id', :text => 'the_id')
  end

  it 'shows Fieldwork#staff_id' do
    fieldwork.staff_id = 'foobar'

    render

    rendered.should have_selector('.staff_id', :text => 'foobar')
  end

  it 'shows Fieldwork#client_id' do
    fieldwork.client_id = 'abcdef'

    render

    rendered.should have_selector('.client_id', :text => 'abcdef')
  end

  describe 'with a conflict report' do
    let(:conflict_report) do
      %q{
        {
            "Contact": {
                "af72e358": {
                    "contact_disposition": {
                        "current": "0",
                        "original": "-4",
                        "proposed": "1"
                    }
                },
                "ba8aa819": {
                    "contact_language_code": {
                        "current": "1",
                        "original": "-4",
                        "proposed": "2"
                    }
                }
            },
            "Event": {
                "44ee9403": {
                    "event_end_time": {
                        "current": "14:45",
                        "original": "",
                        "proposed": "15:00"
                    },
                    "event_start_time": {
                        "current": "13:30",
                        "original": "",
                        "proposed": "14:30"
                    }
                }
            }
        }
      }
    end

    before do
      assign(:conflicts, ConflictReport.new(conflict_report))

      render
    end

    it 'shows entities' do
      rendered.should have_selector('.conflict .entity', :text => 'Contact af72e358')
      rendered.should have_selector('.conflict + .conflict .entity', :text => 'Contact ba8aa819')
      rendered.should have_selector('.conflict + .conflict + .conflict .entity', :text => 'Event 44ee9403')
    end

    it 'shows attribute names' do
      rendered.should have_selector('.conflict[data-entity-type="Contact"][data-public-id="af72e358"] .attribute', :text => 'Contact disposition')
      rendered.should have_selector('.conflict[data-entity-type="Contact"][data-public-id="ba8aa819"] .attribute', :text => 'Contact language code')
      rendered.should have_selector('.conflict[data-entity-type="Event"][data-public-id="44ee9403"] .attribute', :text => 'Event end time')
      rendered.should have_selector('.conflict + .conflict[data-entity-type="Event"][data-public-id="44ee9403"] .attribute', :text => 'Event start time')
    end

    it 'shows current values' do
      rendered.should have_selector('.current[data-name="Contact disposition"]', :text => '0')
      rendered.should have_selector('.current[data-name="Contact language code"]', :text => 'English')
      rendered.should have_selector('.current[data-name="Event end time"]', :text => '14:45')
      rendered.should have_selector('.current[data-name="Event start time"]', :text => '13:30')
    end

    it 'shows original values' do
      rendered.should have_selector('.original[data-name="Contact disposition"]', :text => '-4')
      rendered.should have_selector('.original[data-name="Contact language code"]', :text => 'Missing in Error')
      rendered.should have_selector('.original[data-name="Event end time"]', :text => '')
      rendered.should have_selector('.original[data-name="Event start time"]', :text => '')
    end

    it 'shows proposed values' do
      rendered.should have_selector('.proposed[data-name="Contact disposition"]', :text => '1')
      rendered.should have_selector('.proposed[data-name="Contact language code"]', :text => 'Spanish')
      rendered.should have_selector('.proposed[data-name="Event end time"]', :text => '15:00')
      rendered.should have_selector('.proposed[data-name="Event start time"]', :text => '14:30')
    end
  end
end
