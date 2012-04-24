require 'spec_helper'

module NcsNavigator::Core::Fieldwork
  describe ResponseGroup do
    subject { ResponseGroup.new }

    let(:r1) { stub(:question_id => 'abcdef') }
    let(:r2) { stub(:question_id => '123456') }

    describe '#<<' do
      it 'adds a response to the group' do
        subject << r1

        subject.responses.should == [r1]
      end
    end

    describe '#question_id' do
      it 'returns the question ID of the first response' do
        subject << r1

        subject.question_id.should == r1.question_id
      end

      it 'returns nil if no responses are present' do
        subject.question_id.should be_nil
      end
    end

    describe '#changed?' do
      before do
        subject << r1
        subject << r2
      end

      describe 'if none of the responses have been changed' do
        before do
          r1.stub!(:changed? => false)
          r2.stub!(:changed? => false)
        end

        it 'returns false' do
          subject.should_not be_changed
        end
      end

      describe 'if any of the responses have been changed' do
        before do
          r1.stub!(:changed? => false)
          r2.stub!(:changed? => true)
        end

        it 'returns true' do
          subject.should be_changed
        end
      end
    end

    describe '#persisted?' do
      before do
        subject << r1
        subject << r2
      end

      describe 'if all of the responses are persisted' do
        before do
          r1.stub!(:persisted? => true)
          r2.stub!(:persisted? => true)
        end

        it 'returns true' do
          subject.should be_persisted
        end
      end

      describe 'if one of the responses is not persisted' do
        before do
          r1.stub!(:persisted? => false)
          r2.stub!(:persisted? => true)
        end

        it 'returns false' do
          subject.should_not be_persisted
        end
      end
    end

    describe '#to_model' do
      it 'returns a ResponseGroup containing model conversions' do
        m1 = stub
        r1.stub!(:to_model => m1)

        subject << r1

        subject.to_model.should == ResponseGroup.new([m1])
      end
    end

    describe '#=~' do
      let(:g1) { ResponseGroup.new }
      let(:g2) { ResponseGroup.new }

      describe 'given two empty groups' do
        it 'returns true' do
          g1.should =~ g2
        end
      end

      describe 'given another group of equal length and equal question ID' do
        before do
          g1 << r1
          g2 << r1
        end

        it 'returns true' do
          g1.should =~ g2
        end
      end

      describe 'given another group of equal length and unequal question ID' do
        before do
          g1 << r1
          g2 << r2
        end

        it 'returns false' do
          g1.should_not =~ g2
        end
      end

      describe 'given another group of unequal length and equal question ID' do
        before do
          g1 << r1
          g2 << r1
          g2 << r1
        end

        it 'returns false' do
          g1.should_not =~ g2
        end
      end
    end
  end
end
