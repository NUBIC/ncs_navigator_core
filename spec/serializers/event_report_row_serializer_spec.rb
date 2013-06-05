require 'spec_helper'

describe EventReportRowSerializer do
  let(:e) { Event.new }
  let(:serializer) { EventReportRowSerializer.new(e) }
  let(:json) { JSON.parse(serializer.to_json) }

  # Disable root generation: we're not going to have a root when this is used
  # in EventReportSerializer.
  around do |example|
    begin
      old_root = serializer.root_name
      serializer.class.root = false
      example.call
    ensure
      serializer.class.root = old_root
    end
  end

  it "writes the event's disposition" do
    # In MDES 3.1, this has text "Not attempted".  Keep this in sync if the
    # mapping changes.
    e.event_disposition_category_code = 1
    e.event_disposition = 10

    json['disposition_code']['disposition'].should == 'Not attempted'
  end

  describe 'if the event does not have a disposition' do
    it 'writes null for disposition' do
      json['disposition_code']['disposition'].should be_nil
    end
  end

  describe 'with a participant' do
    before do
      p = Factory(:participant, :p_id => 'foo-bar-baz')
      pe = Factory(:person, :first_name => 'Jane', :last_name => 'Smith')
      p.person = pe
      e.participant = p
    end

    it "writes the participant's given name" do
      json['participant_first_name'].should == 'Jane'
    end

    it "writes the participant's surname" do
      json['participant_last_name'].should == 'Smith'
    end
  end

  describe 'if the event does not have a participant' do
    before do
      e.participant = nil
    end

    it 'writes null for participant ID' do
      json['participant_id'].should be_nil
    end

    it "writes null for the participant's given name" do
      json['participant_first_name'].should be_nil
    end

    it "writes null for the participant's surname" do
      json['participant_last_name'].should be_nil
    end
  end
end
