require 'spec_helper'

require File.expand_path('../activity_label_helpers', __FILE__)

module Psc
  describe InstrumentPlanCollection do
    let(:list) { [] }
    let(:coll) { InstrumentPlanCollection.new(list) }

    let(:sa1) { stub }
    let(:sa2) { stub }
    let(:c1) { stub }
    let(:e1) { stub }
    let(:c2) { stub }
    let(:e2) { stub }

    describe '#group' do
      before do
        list << sa1
        list << sa2

        sa1.stub!(:contact => c1, :event => e1)
        sa2.stub!(:contact => c2, :event => e2)

        coll.group
      end

      it 'groups activities by [contact, event]' do
        coll.groups.should == {
          [c1, e1] => [sa1],
          [c2, e2] => [sa2]
        }
      end
    end

    describe '#calculate' do
      include ActivityLabelHelpers

      describe 'for each [contact, event]' do
        let(:i1) { stub(:name => 'foo') }
        let(:s1) { stub(:order => nil, :access_code => al('instrument:3.0:foo')) }
        let(:s2) { stub(:order => al('order:01_02')) }
        let(:s3) { stub(:order => al('order:01_01')) }
        let(:sr1) { stub(:access_code => al('references:3.0:foo')) }
        let(:sr2) { stub(:access_code => al('references:3.0:foo')) }

        let(:sa1) { stub }
        let(:sa2) { stub }
        let(:sa3) { stub }

        before do
          sa1.stub!(:contact => c1, :event => e1, :instrument => i1, :survey => s1)
          sa2.stub!(:contact => c1, :event => e1, :instrument => nil, :referenced_survey => sr1, :survey => s2)
          sa3.stub!(:contact => c1, :event => e1, :instrument => nil, :referenced_survey => sr2, :survey => s3)
        end

        describe 'the generated plan' do
          let(:plan) { coll.first }

          before do
            # Activities are added out-of-order to test sorting.
            list << sa2
            list << sa1
            list << sa3

            coll.calculate
          end

          it 'has the instrument as its root' do
            plan.root.should == i1
          end

          it 'has ordered surveys' do
            plan.surveys.should == [s1, s3, s2]
          end
        end
      end
    end
  end
end
