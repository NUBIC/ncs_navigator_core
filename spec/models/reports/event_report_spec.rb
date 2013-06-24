require 'spec_helper'

module Reports
  describe EventReport do
    let(:psc) { double }

    describe '#initialize' do
      it 'raises if a date range is not present' do
        expect { Reports::EventReport.new([1], ['abc123'], '', psc) }.to raise_error(ArgumentError, 'a date range must be specified')
      end
    end

    describe '#start_date' do
      let(:report) { Reports::EventReport.new([1], ['abc123'], range, psc) }

      describe 'for date range [,D]' do
        let(:range) { '[,2000-01-01]' }

        it 'is blank' do
          report.start_date.should be_blank
        end
      end

      describe 'for date range [D,]' do
        let(:range) { '[2000-01-01,]' }

        it 'is D' do
          report.start_date.should == '2000-01-01'
        end
      end
    end

    describe '#end_date' do
      let(:report) { Reports::EventReport.new([1], ['abc123'], range, psc) }

      describe 'for date range [,D]' do
        let(:range) { '[,2000-01-01]' }

        it 'is D' do
          report.end_date.should == '2000-01-01'
        end
      end

      describe 'for date range [D,]' do
        let(:range) { '[2000-01-01,]' }

        it 'is blank' do
          report.end_date.should be_blank
        end
      end
    end
  end
end
