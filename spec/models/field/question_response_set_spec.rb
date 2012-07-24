require 'spec_helper'

module Field
  describe QuestionResponseSet do
    let(:group) { QuestionResponseSet.new }
    let(:r1) { stub(:question_id => 'foo').as_null_object }
    let(:r2) { stub(:question_id => 'bar').as_null_object }

    describe '#<<' do
      it 'adds responses to the group' do
        group << r1

        group.length.should == 1
      end

      describe 'when two responses do not have the same question ID' do
        it 'raises an error' do
          group << r1

          lambda { group << r2 }.should raise_error
        end
      end
    end

    describe '#blank?' do
      describe 'if a QuestionResponseSet has no responses' do
        it 'returns true' do
          group.should be_blank
        end
      end

      describe 'if a QuestionResponseSet has a response' do
        before do
          group << stub.as_null_object
        end

        it 'returns false' do
          group.should_not be_blank
        end
      end
    end

    describe '#==' do
      let(:g1) { QuestionResponseSet.new }
      let(:g2) { QuestionResponseSet.new }

      describe 'if g1 and g2 do not address the same question ID' do
        before do
          r1.stub!(:question_id => 'foo', :answer_id => 'foo', :response_group => 'bar', :value => 'baz')
          r2.stub!(:question_id => 'bar', :answer_id => 'foo', :response_group => 'bar', :value => 'baz')

          g1 << r1
          g2 << r2
        end

        it 'returns false' do
          g1.should_not == g2
        end
      end

      describe 'if g1 and g2 contain the same (answer, response group, value) triples' do
        before do
          r1.stub!(:answer_id => 'foo', :response_group => 'bar', :value => 'baz', :question_id => 'grault')
          r2.stub!(:answer_id => 'foo', :response_group => 'bar', :value => 'baz', :question_id => 'grault')

          g1 << r1
          g2 << r2
        end

        it 'returns true' do
          g1.should == g2
        end
      end

      describe 'if g1 and g2 contain different (answer, response group, value) triples' do
        before do
          r1.stub!(:answer_id => 'foo', :response_group => 'bar', :value => 'baz', :question_id => 'grault')
          r2.stub!(:answer_id => 'qux', :response_group => 'quux', :value => 'corge', :question_id => 'grault')

          g1 << r1
          g2 << r2
        end

        it 'returns false' do
          g1.should_not == g2
        end
      end
    end

    describe '#replace' do
      let(:g1) { QuestionResponseSet.new }
      let(:g2) { QuestionResponseSet.new }
    end
  end
end
