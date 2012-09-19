require 'spec_helper'

module Psc
  describe InstrumentPlan do
    let(:plan) { InstrumentPlan.new }

    describe '#id' do
      describe 'given a root' do
        before do
          plan.root = stub(:fingerprint => 'foo')
        end

        it "is its root's fingerprint" do
          plan.id.should == 'foo'
        end
      end

      describe 'without a root' do
        it 'is nil' do
          plan.id.should be_nil
        end
      end
    end
  end
end
