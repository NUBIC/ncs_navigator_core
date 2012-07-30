require 'spec_helper'

module Psc
  describe ScheduledActivity do
    def self.it_maps(mapping)
      from, to = mapping.to_a.first

      it "maps #{from} to #{to}" do
        source = from.split('.').inject(row) { |r, a| r[a] }
        target = sa.send(to)

        target.should == source
      end
    end

    describe '.from_report' do
      let(:row) do
        JSON.parse(%q{
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
        })
      end

      let(:sa) { ScheduledActivity.from_report(row) }

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
      let(:row) do
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
              "labels": "event:birth instrument:ins_que_birth_int_ehpbhi_p2_v2.0 order:01_01 participant_type:self"
          }
        })
      end

      let(:sa) { ScheduledActivity.from_schedule(row) }

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
  end
end
