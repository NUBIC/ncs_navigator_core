require 'spec_helper'

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

      let(:r1) { stub('r1').as_null_object }
      let(:r2) { stub('r2').as_null_object }
      let(:r3) { stub('r3').as_null_object }

      def merge!
        report.merge!
      end

      before do
        report.rows = [r1, r2, r3]
      end

      it 'merges contacts' do
        r1.stub(:contact => c1)
        r2.stub(:contact => c1)
        r3.stub(:contact => c2)

        merge!

        report.rows.map(&:contact).should == [c1, c2]
      end

      it 'maps contacts to their events' do
        r1.stub(:contact => c1, :event => e1)
        r2.stub(:contact => c1, :event => e2)
        r3.stub(:contact => c2, :event => nil)

        merge!

        report.events_for(c1).should == [e1, e2]
        report.events_for(c2).should == []
      end

      it 'maps (contact, event) to instruments' do
        r1.stub(:contact => c1, :event => e1, :instrument => i1)
        r2.stub(:contact => c1, :event => e2, :instrument => i2)
        r3.stub(:contact => c2, :event => nil, :instrument => nil)

        merge!

        report.instruments_for(c1, e1).should == [i1]
        report.instruments_for(c1, e2).should == [i2]
      end

      it 'maps nonexistent (contact, event) pairs to []' do
        r3.stub(:contact => c2, :event => nil, :instrument => nil)

        merge!

        report.instruments_for(c2, e1).should == []
        report.instruments_for(c2, e2).should == []
      end
    end
  end
end
