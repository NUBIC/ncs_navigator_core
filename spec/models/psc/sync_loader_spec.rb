require 'spec_helper'

module Psc
  describe SyncLoader do
    let(:sync_key) do
      lambda { |*c| "test:#{c.join(':')}" }
    end

    let(:loader) { SyncLoader.new(sync_key) }
    let(:redis) { Rails.application.redis }

    before do
      redis.flushdb

      loader.redis = redis
    end

    let(:a_psc_event_type) { 13 }
    let(:a_non_psc_event_type) { 1 }

    let(:p) { Participant.new(:p_id => 'P') }
    let(:et) { NcsCode.new(:display_text => 'Foo Bar', :local_code => a_psc_event_type) }
    let(:e) do
      Event.new(:event_id => 'E',
                :event_start_date => '2000-01-01',
                :event_end_date => '2000-02-01',
                :event_type => et)
    end

    let(:is) { NcsCode.new(:display_text => 'Foobar') }

    let(:c) { Contact.new(:contact_id => 'C', :contact_date => '2000-01-01') }
    let(:cl) { ContactLink.new(:contact_link_id => 'CL') }

    describe '#cache_participant' do
      it "records the participant's public ID" do
        loader.cache_participant(p)

        redis.sismember('test:participants', 'P').should be_true
      end
    end

    describe '#cache_event' do
      let(:cached_event) do
        loader.cache_event(e, p)

        redis.hgetall('test:event:E')
      end

      it 'links the event and participant' do
        loader.cache_event(e, p)

        redis.sismember('test:p:P:events', 'E').should be_true
      end

      describe 'if the event is new' do
        before do
          e.stub!(:new_record? => true)
        end

        it "records the event's status as 'new'" do
          cached_event['status'].should == 'new'
        end
      end

      describe 'if the event is not new' do
        before do
          e.stub!(:new_record? => false)
        end

        it "records the event's status as 'changed'" do
          cached_event['status'].should == 'changed'
        end
      end

      it "records the event's public ID" do
        cached_event['event_id'].should == 'E'
      end

      it "records the event's start date" do
        cached_event['start_date'].should == '2000-01-01'
      end

      it "records the event's end date" do
        cached_event['end_date'].should == '2000-02-01'
      end

      it "records the event's type code" do
        cached_event['event_type_code'].should == '13'
      end

      it "records the event's type label" do
        cached_event['event_type_label'].should == e.label
      end

      it "records whether the event is completed" do
        e.stub!(:completed? => true)

        cached_event['completed'].should be_true
      end

      describe 'if the participant is on the low-intensity arm' do
        before do
          p.stub!(:low_intensity? => true)
        end

        it "records the recruitment arm as 'lo'" do
          cached_event['recruitment_arm'].should == 'lo'
        end
      end

      describe 'if the participant is on the high-intensity arm' do
        before do
          p.stub!(:low_intensity? => false)
        end

        it "records the recruitment arm as 'hi'" do
          cached_event['recruitment_arm'].should == 'hi'
        end
      end

      it 'generates a sort key for the event' do
        cached_event['sort_key'].should == '2000-01-01:013'
      end

      it 'ignores events that cannot be represented in PSC' do
        e.event_type = NcsCode.new(:display_text => 'Quux', :local_code => a_non_psc_event_type)

        cached_event.should be_empty
      end

      describe 'when there is no start date, but there is an end date' do
        before do
          e.event_start_date = nil
        end

        it 'uses the end date as the start date' do
          cached_event['start_date'].should == '2000-02-01'
        end

        it 'uses the end date in the sort key' do
          cached_event['sort_key'].should == '2000-02-01:013'
        end
      end

      describe 'when there is no start date or end date' do
        let(:bad_e) { Event.new(:event_id => 'e_foo', :event_type_code => 15) }

        it 'cannot be cached' do
          expect { loader.cache_event(bad_e, p) }.
            to raise_error("Event \"e_foo\" has no start or end dates. It cannot be sync'd to PSC.")
        end
      end
    end

    describe '#cache_contact_link' do
      def cache_contact_link
        loader.cache_contact_link(cl, c, e, p)
      end

      let(:cached_link) do
        cache_contact_link

        redis.hgetall('test:link_contact:CL')
      end

      describe 'if the contact link is new' do
        before do
          cl.stub!(:new_record? => true)
        end

        it "records the contact link's status as 'new'" do
          cached_link['status'].should == 'new'
        end
      end

      describe 'if the contact link is not new' do
        before do
          cl.stub!(:new_record? => false)
        end

        it "records the contact link's status as 'changed'" do
          cached_link['status'].should == 'changed'
        end
      end

      it "records the contact link's public ID" do
        cached_link['contact_link_id'].should == 'CL'
      end

      it "records the event's public ID" do
        cached_link['event_id'].should == 'E'
      end

      it "records the contact's public ID" do
        cached_link['contact_id'].should == 'C'
      end

      it "records the contact's date" do
        cached_link['contact_date'].should == '2000-01-01'
      end

      it "generates a sort key for the link" do
        cached_link['sort_key'].should == 'E:2000-01-01'
      end

      it 'links the contact to the participant and event' do
        cache_contact_link

        redis.sismember('test:p:P:link_contacts:E', cl.public_id).should be_true
      end

      it 'ignores links for events that cannot be represented in PSC' do
        e.event_type = NcsCode.new(:display_text => 'Quux', :local_code => a_non_psc_event_type)

        cached_link.should be_empty
      end
    end

    describe '#cached_participant_ids' do
      before do
        loader.cache_participant(p)
      end

      it 'returns public IDs of cached participants' do
        loader.cached_participant_ids.should == ['P']
      end
    end

    describe '#cached_events' do
      before do
        loader.cache_event(e, p)
      end

      it 'returns public IDs of cached events' do
        loader.cached_event_ids.should == ['E']
      end
    end

    describe '#cached_contact links' do
      before do
        loader.cache_contact_link(cl, c, e, p)
      end

      it 'returns public IDs of cached contact links' do
        loader.cached_contact_link_ids.should == ['CL']
      end
    end
  end
end
