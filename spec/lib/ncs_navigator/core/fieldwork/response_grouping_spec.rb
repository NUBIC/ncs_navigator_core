require 'spec_helper'

module NcsNavigator::Core::Fieldwork
  describe ResponseGrouping do
    include Adapters

    describe '#group_responses' do
      let(:or1) { stub(:question_id => 'q1') }
      let(:cr1) { stub(:question_id => 'q1') }
      let(:pr1) { stub(:question_id => 'q1') }
      let(:or2) { stub(:question_id => 'q2') }
      let(:cr2) { stub(:question_id => 'q2') }
      let(:pr2) { stub(:question_id => 'q2') }

      subject do
        Class.new do
          include ResponseGrouping

          attr_accessor :responses
        end.new
      end

      before do
        subject.responses = {
          'abc123' => {
            :original => or1,
            :current => cr1,
            :proposed => pr1
          },
          'xyz456' => {
            :original => or2,
            :current => cr2,
            :proposed => pr2
          }
        }

        subject.group_responses
      end

      it 'groups responses by question ID' do
        subject.response_groups.should == {
          'q1' => {
            :original => Group.new([or1]),
            :current => Group.new([cr1]),
            :proposed => Group.new([pr1])
          },
          'q2' => {
            :original => Group.new([or2]),
            :current => Group.new([cr2]),
            :proposed => Group.new([pr2])
          }
        }
      end
    end

    describe Group do
      subject { Group.new }

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
        let(:g1) { Group.new }
        let(:g2) { Group.new }

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
end
