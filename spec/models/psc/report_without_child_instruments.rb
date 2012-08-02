require 'spec_helper'

shared_context 'report without child instruments' do
  let(:data) do
    JSON.parse(%q{
      {
          "filters": {
              "end_date": "2012-07-16",
              "responsible_user": "user",
              "start_date": "2012-07-09",
              "states": [
                  "Scheduled"
              ]
          },
          "rows": [
              {
                  "activity_name": "Low-Intensity Interview",
                  "activity_status": "Scheduled",
                  "activity_type": "Instrument",
                  "grid_id": "ccb30379-b036-45a2-881b-454e9b42389d",
                  "ideal_date": "2012-07-06",
                  "labels": [
                      "event:low_intensity_data_collection",
                      "instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
                  ],
                  "responsible_user": "user",
                  "scheduled_date": "2012-07-10",
                  "scheduled_study_segment": {
                      "grid_id": "7b3f6868-13cf-4c7b-9f16-d2b2eee08fbc",
                      "start_date": "2012-07-06",
                      "start_day": 1
                  },
                  "site": "GCSC",
                  "study": "NCS Hi-Lo",
                  "subject": {
                      "grid_id": "7eaf6393-b7a9-4888-b32f-d6bde6436b3e",
                      "name": "Liz",
                      "person_id": "2f85c94e-edbb-4cbe-b9ab-5f12c033323f"
                  }
              }
          ]
      }
    })
  end

  let(:activity_name) { 'Low-Intensity Interview' }
  let(:event_data_collection) { 'event:low_intensity_data_collection' }
  let(:event_labels) { [event_data_collection] }
  let(:ideal_date) { '2012-07-06' }
  let(:instrument_pregnotpreg) { 'instrument:ins_que_lipregnotpreg_int_li_p2_v2.0' }
  let(:person_id) { '2f85c94e-edbb-4cbe-b9ab-5f12c033323f' }
  let(:scheduled_date) { '2012-07-10' }
  let(:survey_labels) { [instrument_pregnotpreg] }
end
