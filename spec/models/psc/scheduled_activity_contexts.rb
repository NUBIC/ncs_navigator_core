require 'spec_helper'

shared_context 'from report' do
  let(:row) do
    JSON.parse(%q{
      {
          "activity_name": "Low-Intensity Interview",
          "activity_status": "Scheduled",
          "activity_type": "Instrument",
          "grid_id": "ccb30379-b036-45a2-881b-454e9b42389d",
          "ideal_date": "2012-07-06",
          "labels": [
              "collection:biological",
              "event:birth",
              "instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name",
              "instrument:3.0:ins_que_birth_int_ehpbhi_p2_v3.0_baby_name",
              "order:01_02",
              "participant_type:child",
              "references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0",
              "references:3.0:ins_que_birth_int_ehpbhi_p2_v3.0"
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
    })
  end

  let(:canceled_row) do
    JSON.parse(%q{
      {
          "activity_name": "Low-Intensity Interview",
          "activity_status": "Canceled",
          "activity_type": "Instrument",
          "grid_id": "ccb30379-b036-45a2-881b-454e9b42389d",
          "ideal_date": "2012-07-06",
          "labels": [
              "collection:biological",
              "event:birth",
              "instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name",
              "instrument:3.0:ins_que_birth_int_ehpbhi_p2_v3.0_baby_name",
              "order:01_02",
              "participant_type:child",
              "references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0",
              "references:3.0:ins_que_birth_int_ehpbhi_p2_v3.0"
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
    })
  end

  let(:sa) { Psc::ScheduledActivity.from_report(row) }
  let(:canceled_sa) { Psc::ScheduledActivity.from_report(canceled_row) }
end

shared_context 'from schedule' do
  let(:row) do
    JSON.parse(%q{
      {
          "activity": {
              "name": "Birth Interview",
              "type": "Instrument"
          },
          "assignment": {
              "id": "mother",
              "subject_coordinator": {
                  "username": "abc123"
              }
          },
          "current_state": {
              "date": "2011-01-01",
              "name": "scheduled",
              "time": "14:10"
          },
          "id": "11",
          "ideal_date": "2011-01-01",
          "labels": "event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name instrument:3.0:ins_que_birth_int_ehpbhi_p2_v3.0_baby_name references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0 references:3.0:ins_que_birth_int_ehpbhi_p2_v3.0 order:01_02 participant_type:child collection:biological",
          "study_segment": "HI-Intensity: Child"
      }
    })
  end

  let(:row_without_time) do
    JSON.parse(%q{
      {
          "activity": {
              "name": "Birth Interview",
              "type": "Instrument"
          },
          "assignment": {
              "id": "mother"
          },
          "current_state": {
              "name": "scheduled",
              "date": "2011-01-01"
          },
          "study_segment": "HI-Intensity: Child",
          "id": "11",
          "ideal_date": "2011-01-01",
          "labels": "event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name instrument:3.0:ins_que_birth_int_ehpbhi_p2_v3.0_baby_name references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0 references:3.0:ins_que_birth_int_ehpbhi_p2_v3.0 order:01_02 participant_type:child collection:biological"
      }
    })
  end

  let(:canceled_row) do
    JSON.parse(%q{
      {
          "activity": {
              "name": "Birth Interview",
              "type": "Instrument"
          },
          "assignment": {
              "id": "mother"
          },
          "current_state": {
              "name": "canceled",
              "date": "2011-01-01"
          },
          "study_segment": "HI-Intensity: Child",
          "id": "11",
          "ideal_date": "2011-01-01",
          "labels": "event:birth instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name instrument:3.0:ins_que_birth_int_ehpbhi_p2_v3.0_baby_name references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0 references:3.0:ins_que_birth_int_ehpbhi_p2_v3.0 order:01_02 participant_type:child collection:biological"
      }
    })
  end

  let(:sa) { Psc::ScheduledActivity.from_schedule(row) }
  let(:canceled_sa) { Psc::ScheduledActivity.from_schedule(canceled_row) }
  let(:sa_without_time) { Psc::ScheduledActivity.from_schedule(row_without_time) }
end
