require 'spec_helper'

module Field::Adapters
  describe Response::ModelAdapter do
    let(:q) { Factory(:question) }
    let(:a) { Factory(:answer) }
    let(:resp) { Factory(:response, :question => q, :answer => a) }
    let(:adapter) { Response::ModelAdapter.new(resp) }

    describe '#question_public_id' do
      describe 'if no question is present' do
        before do
          resp.question = nil
        end

        it 'returns nil' do
          adapter.question_public_id.should be_nil
        end
      end

      it "returns its question's API ID" do
        adapter.question_public_id.should == q.api_id
      end

      describe 'if #source is set' do
        before do
          ha = Response::HashAdapter.new({})
          ha.question_id = 'foo'
          adapter.source = ha
        end

        it "returns its source's question ID" do
          adapter.question_public_id.should == 'foo'
        end
      end
    end

    describe '#answer_public_id' do
      describe 'if no answer is present' do
        before do
          resp.answer = nil
        end

        it 'returns nil' do
          adapter.answer_public_id.should be_nil
        end
      end

      it "returns its answer's API ID" do
        adapter.answer_public_id.should == a.api_id
      end

      describe 'if #source is set' do
        before do
          ha = Response::HashAdapter.new({})
          ha.answer_id = 'foo'
          adapter.source = ha
        end

        it "returns its source's answer ID" do
          adapter.answer_public_id.should == 'foo'
        end
      end
    end

    describe '#unresolved_references' do
      describe 'if #source is not set' do
        before do
          adapter.source = nil
        end

        it 'is empty' do
          adapter.unresolved_references.should be_empty
        end
      end

      let(:ha) { Response::HashAdapter.new({}) }

      before do
        adapter.source = ha
      end

      it 'returns the answer public ID' do
        ha.answer_id = 'foo'

        adapter.unresolved_references[::Answer].should == 'foo'
      end

      it 'returns the question public ID' do
        ha.question_id = 'bar'

        adapter.unresolved_references[::Question].should == 'bar'
      end

      it 'returns the response set public ID' do
        hrs = ResponseSet::HashAdapter.new('uuid' => 'baz')
        ha.ancestors = { :response_set => hrs }

        adapter.unresolved_references[::ResponseSet].should == 'baz'
      end
    end

    describe '#ensure_prerequisites' do
      it 'fills in #answer_id'

      it 'fills in #question_id'

      it 'fills in #response_set_id'
    end
  end
end
