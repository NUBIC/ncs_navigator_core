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
                    "disposition": {
                        "current": "0",
                        "original": "-4",
                        "proposed": "1"
                    }
                },
                "ba8aa819": {
                    "language": {
                        "current": "1",
                        "original": "-4",
                        "proposed": "2"
                    }
                }
            },
            "Event": {
                "44ee9403": {
                    "end_time": {
                        "current": "14:45",
                        "original": "",
                        "proposed": "15:00"
                    },
                    "start_time": {
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
      rendered.should have_selector('.conflict[data-entity-type="Contact"][data-public-id="af72e358"] .attribute', :text => 'Disposition')
      rendered.should have_selector('.conflict[data-entity-type="Contact"][data-public-id="ba8aa819"] .attribute', :text => 'Language')
      rendered.should have_selector('.conflict[data-entity-type="Event"][data-public-id="44ee9403"] .attribute', :text => 'End time')
      rendered.should have_selector('.conflict + .conflict[data-entity-type="Event"][data-public-id="44ee9403"] .attribute', :text => 'Start time')
    end

    it 'shows current values' do
      rendered.should have_selector('.current[data-name="Disposition"]', :text => '0')
      rendered.should have_selector('.current[data-name="Language"]', :text => '1')
      rendered.should have_selector('.current[data-name="End time"]', :text => '14:45')
      rendered.should have_selector('.current[data-name="Start time"]', :text => '13:30')
    end

    it 'shows original values' do
      rendered.should have_selector('.original[data-name="Disposition"]', :text => '-4')
      rendered.should have_selector('.original[data-name="Language"]', :text => '-4')
      rendered.should have_selector('.original[data-name="End time"]', :text => '')
      rendered.should have_selector('.original[data-name="Start time"]', :text => '')
    end

    it 'shows proposed values' do
      rendered.should have_selector('.proposed[data-name="Disposition"]', :text => '1')
      rendered.should have_selector('.proposed[data-name="Language"]', :text => '2')
      rendered.should have_selector('.proposed[data-name="End time"]', :text => '15:00')
      rendered.should have_selector('.proposed[data-name="Start time"]', :text => '14:30')
    end
  end
end
