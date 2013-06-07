require 'spec_helper'

describe EventReportSerializer do
  let(:rep) { stub(:rows => [e]) }
  let(:e) { Event.new }
  let(:serializer) { EventReportSerializer.new(rep) }
  let(:json) { JSON.parse(serializer.to_json) }

  it 'generates one row per event' do
    json['events'].length.should == 1
  end

  describe 'a row' do
    # We've only got one row.
    let(:row) { json['events'].first }

    it "contains the event's disposition" do
      # In MDES 3.1, this has text "Not attempted".  Keep this in sync if the
      # mapping changes.
      e.event_disposition_category_code = 1
      e.event_disposition = 10

      row['disposition_code']['disposition'].should == 'Not attempted'
    end

    describe 'if the event does not have a disposition' do
      it 'writes null for disposition' do
        row['disposition_code']['disposition'].should be_nil
      end
    end

    describe 'with a participant' do
      before do
        p = Factory(:participant, :p_id => 'foo-bar-baz')
        pe = Factory(:person, :first_name => 'Jane', :last_name => 'Smith')
        p.person = pe
        e.participant = p
      end

      it "writes the public ID of the event's participant" do
        row['participant_id'].should == 'foo-bar-baz'
      end

      it "writes the participant's given name" do
        row['participant_first_name'].should == 'Jane'
      end

      it "writes the participant's surname" do
        row['participant_last_name'].should == 'Smith'
      end
    end

    describe 'if the event does not have a participant' do
      before do
        e.participant = nil
      end

      it 'writes null for participant ID' do
        row['participant_id'].should be_nil
      end

      it "writes null for the participant's given name" do
        row['participant_first_name'].should be_nil
      end

      it "writes null for the participant's surname" do
        row['participant_last_name'].should be_nil
      end
    end
  end
end
