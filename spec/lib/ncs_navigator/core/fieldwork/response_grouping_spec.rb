require 'spec_helper'

module NcsNavigator::Core::Fieldwork
  describe ResponseGrouping do
    include Adapters

    subject do
      Class.new do
        include ResponseGrouping

        attr_accessor :response_groups
        attr_accessor :responses

        def initialize
          self.responses = {}
          self.response_groups = {}
        end
      end.new
    end

    let(:or1) { stub(:question_id => 'q1') }
    let(:cr1) { stub(:question_id => 'q1') }
    let(:pr1) { stub(:question_id => 'q1') }
    let(:or2) { stub(:question_id => 'q2') }
    let(:cr2) { stub(:question_id => 'q2') }
    let(:pr2) { stub(:question_id => 'q2') }

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
    end

    describe '#group_responses' do
      before do
        subject.group_responses
      end

      it 'groups responses by question ID' do
        subject.response_groups.should == {
          'q1' => {
            :original => [or1],
            :current => [cr1],
            :proposed => [pr1]
          },
          'q2' => {
            :original => [or2],
            :current => [cr2],
            :proposed => [pr2]
          }
        }
      end
    end
  end
end
