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
