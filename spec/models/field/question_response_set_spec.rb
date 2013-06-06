require 'spec_helper'

module Field
  describe QuestionResponseSet do
    include Field::Adoption

    let(:group) { QuestionResponseSet.new }
    let(:q1) { Factory(:question) }
    let(:q2) { Factory(:question) }
    let(:a1) { Factory(:answer, :question => q1) }
    let(:a2) { Factory(:answer, :question => q2) }
    let(:a3) { Factory(:answer, :question => q1) }
    let(:r1) { adapt_model(Factory(:response, :question => q1, :answer => a1)) }
    let(:r1b) { adapt_model(Factory(:response, :question => q1, :answer => a3)) }
    let(:r2) { adapt_model(Factory(:response, :question => q2, :answer => a2)) }

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

    describe '#public_id' do
      it "is the API ID of the first response's question" do
        group << r1

        group.public_id.should == r1.question_public_id
      end
    end

    describe '#patch' do
      before do
        group << r1

        group.patch(QuestionResponseSet.new(r1b))
      end

      it 'marks all its existing responses for destruction' do
        r1.should be_marked_for_destruction
      end

      it 'adds responses from another set' do
        group.length.should == 2
      end

      describe 'on itself' do
        it 'does not change the group' do
          group = QuestionResponseSet.new(r1)

          group.patch(group)

          group.should_not be_changed
        end
      end
    end

    describe '#pending_prerequisites' do
      let(:group) { QuestionResponseSet.new(r1, r1b) }

      before do
        r1.stub!(:pending_prerequisites => { ::Answer => ['foo'] })
        r1b.stub!(:pending_prerequisites => { ::Answer => ['bar'] })
      end

      it 'returns pending prerequisites of its responses' do
        group.pending_prerequisites.should == {
          ::Answer => ['foo', 'bar']
        }
      end
    end

    describe '#pending_postrequisites' do
      let(:group) { QuestionResponseSet.new(r1, r1b) }

      before do
        r1.stub!(:pending_postrequisites => { ::Answer => ['foo'] })
        r1b.stub!(:pending_postrequisites => { ::Answer => ['bar'] })
      end

      it 'returns pending postrequisites of its responses' do
        group.pending_postrequisites.should == {
          ::Answer => ['foo', 'bar']
        }
      end
    end

    describe '#to_model' do
      it 'returns itself' do
        group.to_model.should == group
      end
    end

    describe '#save' do
      it 'saves responses' do
        r1.should_receive(:save).and_return(true)

        group << r1

        group.save
      end

      it 'destroys responses marked for destruction' do
        r1.mark_for_destruction

        group << r1

        group.save

        r1.should be_destroyed
      end

      it 'destroys first, saves later' do
        # If this example doesn't go well, you'll see a constraint violation
        # on Response#api_id.
        #
        # This sort of thing happens when receiving updated data for existing
        # responses.
        r1 = adapt_model(Factory(:response, :question => q1, :answer => a1, :api_id => 'foo'))
        rs = Factory(:response_set)
        r2 = adapt_model(Response.new(:question => q1, :answer => a3, :api_id => 'foo', :response_set => rs))

        r1.mark_for_destruction

        group << r2
        group << r1

        group.save.should be_true
      end
    end

    describe '#changed?' do
      it 'is initially false' do
        group.should_not be_changed
      end

      describe 'with an initial set' do
        it 'is false' do
          group = QuestionResponseSet.new(r1)

          group.should_not be_changed
        end
      end

      describe 'after adding a response' do
        before do
          group << r1
        end

        it 'is true' do
          group.should be_changed
        end
      end

      describe 'after #patch' do
        before do
          group.patch(QuestionResponseSet.new(r1b))
        end

        it 'is true' do
          group.should be_changed
        end

        describe 'and successful save' do
          before do
            r1.stub!(:save => true)

            group << r1
            group.save
          end

          it 'is false' do
            group.should_not be_changed
          end
        end

        describe 'and unsuccessful save' do
          before do
            r1.stub!(:save => false)

            group << r1
            group.save
          end

          it 'is true' do
            group.should be_changed
          end
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
          r1.stub!(:question_public_id => 'foo', :answer_public_id => 'foo', :response_group => 'bar', :value => 'baz')
          r2.stub!(:question_public_id => 'bar', :answer_public_id => 'foo', :response_group => 'bar', :value => 'baz')

          g1 << r1
          g2 << r2
        end

        it 'returns false' do
          g1.should_not == g2
        end
      end

      describe 'if g1 and g2 contain the same (answer, response group, value) triples' do
        before do
          r1.stub!(:answer_public_id => 'foo', :response_group => 'bar', :value => 'baz', :question_public_id => 'grault')
          r2.stub!(:answer_public_id => 'foo', :response_group => 'bar', :value => 'baz', :question_public_id => 'grault')

          g1 << r1
          g2 << r2
        end

        it 'returns true' do
          g1.should == g2
        end
      end

      describe 'if g1 and g2 contain different (answer, response group, value) triples' do
        before do
          r1.stub!(:answer_public_id => 'foo', :response_group => 'bar', :value => 'baz', :question_public_id => 'grault')
          r2.stub!(:answer_public_id => 'qux', :response_group => 'quux', :value => 'corge', :question_public_id => 'grault')

          g1 << r1
          g2 << r2
        end

        it 'returns false' do
          g1.should_not == g2
        end
      end
    end
  end
end
