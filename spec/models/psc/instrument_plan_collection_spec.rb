require 'spec_helper'

module Psc
  describe InstrumentPlanCollection do
    let(:coll) { InstrumentPlanCollection.new }

    let(:sa1) { stub }
    let(:sa2) { stub }
    let(:c1) { stub }
    let(:e1) { stub }
    let(:c2) { stub }
    let(:e2) { stub }

    describe '#group' do
      before do
        coll.add_activity(sa1)
        coll.add_activity(sa2)

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
      describe 'for each [contact, event]' do
        let(:i1) { stub(:name => 'foo') }
        let(:s1) { stub }
        let(:s2) { stub }

        let(:sa3) { stub }

        before do
          sa1.stub!(:contact => c1, :event => e1, :instrument => i1, :survey => s1, :order_label => nil)
          sa2.stub!(:contact => c1, :event => e1, :instrument => nil, :referenced_survey => s1, :survey => s2, :order_label => '01_02')
          sa3.stub!(:contact => c1, :event => e1, :instrument => nil, :referenced_survey => s1, :survey => s2, :order_label => '01_01')
        end

        describe 'the generated plan' do
          let(:plan) { coll.first }

          before do
            # Activities are added out-of-order to test sorting.
            coll.add_activity(sa2)
            coll.add_activity(sa1)
            coll.add_activity(sa3)

            coll.calculate
          end

          it 'has the instrument as its root' do
            plan.root.should == i1
          end

          it 'orders the activities' do
            plan.activities.should == [sa1, sa3, sa2]
          end
        end
      end
    end
  end
end
