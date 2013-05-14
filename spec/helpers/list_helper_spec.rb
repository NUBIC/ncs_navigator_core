# -*- coding: utf-8 -*-


require 'spec_helper'

describe ListHelper do
  describe '#sort_by_started_at' do
    before do
      InstrumentPlan.stub!(:from_schedule).and_return(InstrumentPlan.new)
      @mother = Factory(:person)
      @m_participant = Factory(:participant)
      @m_participant.person = @mother
      @m_participant.save!

      @child = Factory(:person)
      @child.save!
      @c_participant = @m_participant.create_child_participant!(@child)

      # Event withough start date, time or contact_link
      @event = Factory(:event,
                        :participant => @m_participant,
                        :event_start_date => Date.new(2012,7,7),
                        :event_start_time => '22:37'
                      )
      # Event with start date, time and a contact_link
      @cl_ev = Factory(:event,
                        :participant => @m_participant,
                        :event_start_date => Date.new(2012,7,7),
                        :event_start_time => '20:33'
                      )
      # Contact_link not associated with an event
      c1 = Factory(:contact)
      c1.contact_date_date = Date.new(2012,8,8)
      c1.contact_start_time = '23:59'
      @cl = Factory(
        :contact_link,
        :person => @mother,
        :provider => nil,
        :contact => c1,
        :event => nil
      )
      # Mother's contact_link associated with mother's event
      @cl_ev_mother = Factory(
        :contact_link,
        :person => @mother,
        :provider => nil,
        :contact => Factory(:contact),
        :event => @cl_ev
      )
      # Child's contact_link associated with mother's event
      @cl_ev_child = Factory(
        :contact_link,
        :person => @child,
        :provider => nil,
        :contact => Factory(:contact),
        :event => @cl_ev
      )
    end

    it "sorts events and contact_links related to the mother by date, time" do
      list = [@event, @cl_ev, @cl]
      sort_by_started_at(list).should == [@cl, @event, @cl_ev]
    end

    it "handles sorting events and contact_links that don't have date or time set" do
      ev_no_date = Factory(:event, :participant => @m_participant)
      list = [@event, @cl_ev, @cl, ev_no_date]
      sort_by_started_at(list).should == [@cl, @event, @cl_ev, ev_no_date]
    end

  end
end
