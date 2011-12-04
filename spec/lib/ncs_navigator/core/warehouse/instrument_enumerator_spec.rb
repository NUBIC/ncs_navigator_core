require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe InstrumentEnumerator do
    it 'is enumerable' do
      InstrumentEnumerator.ancestors.should include(Enumerable)
    end

    describe '.create_transformer' do
      it 'creates a transformer' do
        InstrumentEnumerator.create_transformer(nil).should respond_to(:transform)
      end
    end

    describe '#each' do
      it 'converts every response set in turn' do
        rs1 = mock(ResponseSet)
        rs1.should_receive(:to_mdes_warehouse_records).and_return(%w(A B C))
        rs2 = mock(ResponseSet)
        rs2.should_receive(:to_mdes_warehouse_records).and_return(%w(H4 H7))

        ResponseSet.should_receive(:find_each).and_yield(rs1).and_yield(rs2)

        InstrumentEnumerator.new.to_a.should == %w(A B C H4 H7)
      end
    end
  end
end
