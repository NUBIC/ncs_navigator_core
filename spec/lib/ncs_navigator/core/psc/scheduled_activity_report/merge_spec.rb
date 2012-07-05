# -*- coding: utf-8 -*-
require 'spec_helper'
require 'ostruct'

module NcsNavigator::Core::Psc
  describe ScheduledActivityReport do
    let(:report) { subject }

    describe '#merge' do
      let(:c1) { Contact.new(:contact_id => 'c1') }
      let(:c2) { Contact.new(:contact_id => 'c2') }
      let(:e1) { Event.new(:event_id => 'e1') }
      let(:e2) { Event.new(:event_id => 'e2') }
      let(:i1) { Instrument.new(:instrument_id => 'i1') }
      let(:i2) { Instrument.new(:instrument_id => 'i2') }

      let(:r1) { OpenStruct.new }
      let(:r2) { OpenStruct.new }
      let(:r3) { OpenStruct.new }

      before do
        report.rows = [r1, r2, r3]
      end

      it 'merges contacts' do
        r1.contact = c1
        r2.contact = c1
        r3.contact = c2

        rows, _, _ = report.merge

        rows.map(&:contact).should == [c1, c2]
      end

      it 'maps contacts to their events' do
        r1.contact = c1; r1.event = e1
        r2.contact = c1; r2.event = e2
        r3.contact = c2; r3.event = nil

        _, event_map, _ = report.merge

        event_map[c1.public_id].should == [e1, e2]
        event_map[c2.public_id].should == []
      end

      it 'maps (contact, event) to instruments' do
        r1.contact = c1; r1.event = e1;  r1.instrument = i1
        r2.contact = c1; r2.event = e2;  r2.instrument = i2
        r3.contact = c2; r3.event = nil; r3.instrument = nil

        _, _, instrument_map = report.merge

        instrument_map[[c1.public_id, e1.public_id]].should == [i1]
        instrument_map[[c1.public_id, e2.public_id]].should == [i2]
      end

      it 'maps nonexistent (contact, event) pairs to []' do
        r3.contact = c2; r3.event = nil; r3.instrument = nil

        _, _, instrument_map = report.merge

        instrument_map[[c2.public_id, e1.public_id]].should == []
        instrument_map[[c2.public_id, e2.public_id]].should == []
      end
    end
  end
end
