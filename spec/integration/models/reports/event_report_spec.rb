require 'spec_helper'
require 'logger'
require 'stringio'

require File.expand_path('../../../../shared/models/event_psc_linkage', __FILE__)

module Reports
  describe EventReport do
    include_context 'event-PSC linkage'

    let(:rows) { report.rows }

    describe '#run' do
      describe 'with start and end dates' do
        let(:report) { EventReport.new([], [], '[2011-08-01,2011-10-30]', psc) }

        before do
          # helps demonstrate that we look at ideal dates *and* event types
          # when checking implications, i.e. that we use the standard
          # implication rules
          Factory(:event, :psc_ideal_date => pv1_1.psc_ideal_date, :event_type_code => -4)

          report.run
        end

        it 'filters by scheduled date' do
          rows.length.should == 2
        end

        it 'returns events whose scheduled date falls in the given interval' do
          rows.map(&:scheduled_date).all? { |sd| sd.between?('2011-08-01', '2011-10-30') }.should be_true
        end

        it 'returns events implied by the returned activities' do
          rows.should == [screener, pv1_1]
        end
      end

      describe 'given event types and scheduled dates' do
        let(:report) { EventReport.new([pv1_code], [], '[2000-01-01,2011-11-01]', psc) }

        before do
          report.run
        end

        it 'filters by scheduled date' do
          rows.length.should == 1
        end

        it 'returns events whose scheduled date falls in the given interval' do
          rows.map(&:scheduled_date).all? { |sd| sd.between?('2000-01-01', '2011-11-01') }.should be_true
        end

        it 'returns events whose event type is in the type code list' do
          rows.map(&:event_type_code).should == [pv1_code]
        end
      end

      describe 'with start and end dates and data collectors' do
        let(:report) { EventReport.new([], ['abc123'], '[2011-08-01,2011-10-30]', psc) }

        before do
          report.run
        end

        it 'filters by data collector' do
          rows.length.should == 1
        end

        it 'returns events whose data collector is in the accepted set' do
          rows.map(&:data_collectors).flatten.should == ['abc123']
        end
      end
    end
  end
end
