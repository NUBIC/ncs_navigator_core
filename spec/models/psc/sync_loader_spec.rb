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

    describe '#cache_participant' do
      let(:p) { Participant.new(:p_id => 'foo') }

      it "records the participant's public ID" do
        loader.cache_participant(p)

        redis.sismember('test:participants', 'foo').should be_true
      end
    end

    describe '#cache_event' do
      let(:et) { NcsCode.new(:display_text => 'Foo Bar', :local_code => 1) }
      let(:p) { Participant.new(:p_id => 'bar') }

      let(:e) do
        Event.new(:event_id => 'foo',
                  :event_start_date => '2000-01-01',
                  :event_end_date => '2000-02-01',
                  :event_type => et)
      end

      let(:cached_event) do
        loader.cache_event(e, p)

        redis.hgetall('test:event:foo')
      end

      it 'links the event and participant' do
        loader.cache_event(e, p)

        redis.sismember('test:p:bar:events', 'foo').should be_true
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
        cached_event['event_id'].should == 'foo'
      end

      it "records the event's start date" do
        cached_event['start_date'].should == '2000-01-01'
      end

      it "records the event's end date" do
        cached_event['end_date'].should == '2000-02-01'
      end

      it "records the event's type code" do
        cached_event['event_type_code'].should == '1'
      end

      it "records the event's type label" do
        cached_event['event_type_label'].should == e.label
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
        cached_event['sort_key'].should == '2000-01-01:001'
      end
    end

    describe '#cache_contact_link' do
      let(:cl) { ContactLink.new(:contact_link_id => 'cl') }
      let(:c) { Contact.new(:contact_id => 'c', :contact_date => '2000-01-01') }
      let(:i) { nil }
      let(:e) { Event.new(:event_id => 'e') }
      let(:p) { Participant.new(:p_id => 'p') }

      def cache_contact_link
        loader.cache_contact_link(cl, c, i, e, p)
      end

      let(:cached_link) do
        cache_contact_link

        redis.hgetall('test:link_contact:cl')
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
        cached_link['contact_link_id'].should == 'cl'
      end

      it "records the event's public ID" do
        cached_link['event_id'].should == 'e'
      end

      it "records the contact's public ID" do
        cached_link['contact_id'].should == 'c'
      end

      it "records the contact's date" do
        cached_link['contact_date'].should == '2000-01-01'
      end

      describe 'if an instrument is present' do
        let(:is) { NcsCode.new(:display_text => 'Foobar') }

        let(:i) do
          Instrument.new(:instrument_id => 'i',
                         :instrument_type_code => 1,
                         :instrument_status => is)
        end

        it 'generates a sort key using the instrument type code' do
          cached_link['sort_key'].should == 'e:2000-01-01:001'
        end

        it "records the instrument's public ID" do
          cached_link['instrument_id'].should == 'i'
        end

        it "records the instrument's type code" do
          cached_link['instrument_type'].should == '1'
        end

        it "records the text of the instrument's status" do
          cached_link['instrument_status'].should == 'foobar'
        end

        it 'links the link to the participant and instrument' do
          cache_contact_link

          redis.sismember('test:p:p:link_contacts_with_instrument:i', cl.public_id).should be_true
        end
      end

      describe 'if an instrument is not present' do
        it "generates a sort key for the link" do
          cached_link['sort_key'].should == 'e:2000-01-01'
        end

        it 'links the link to the participant and event' do
          cache_contact_link

          redis.sismember('test:p:p:link_contacts_without_instrument:e', cl.public_id).should be_true
        end
      end
    end
  end
end
