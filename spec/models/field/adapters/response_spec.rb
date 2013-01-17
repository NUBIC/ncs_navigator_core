# == Schema Information
#
# Table name: responses
#
#  answer_id         :integer
#  api_id            :string(255)
#  created_at        :datetime
#  datetime_value    :datetime
#  float_value       :float
#  id                :integer          not null, primary key
#  integer_value     :integer
#  lock_version      :integer          default(0)
#  question_id       :integer
#  response_group    :string(255)
#  response_other    :string(255)
#  response_set_id   :integer          not null
#  source_mdes_id    :string(36)
#  source_mdes_table :string(100)
#  string_value      :string(255)
#  survey_section_id :integer
#  text_value        :text
#  unit              :string(255)
#  updated_at        :datetime
#

require 'spec_helper'

module Field::Adapters
  describe Response::ModelAdapter do
    let(:resp) { ::Response.new }
    let(:adapter) { Response::ModelAdapter.new(resp) }

    describe '#question_public_id' do
      let(:q) { Factory(:question) }

      describe 'if no question is present' do
        before do
          resp.question = nil
        end

        it 'returns nil' do
          adapter.question_public_id.should be_nil
        end
      end

      it "returns its question's API ID" do
        resp.question = q

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
      let(:a) { Factory(:answer) }

      describe 'if no answer is present' do
        before do
          resp.answer = nil
        end

        it 'returns nil' do
          adapter.answer_public_id.should be_nil
        end
      end

      it "returns its answer's API ID" do
        resp.answer = a

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

    describe '#response_set_public_id' do
      let(:rs) { Factory(:response_set, :api_id => 'foo') }

      describe 'if no response set is present' do
        before do
          resp.response_set = nil
        end

        it 'returns nil' do
          adapter.response_set_public_id.should be_nil
        end
      end

      it "returns its response set's API ID" do
        resp.response_set = rs

        adapter.response_set_public_id.should == 'foo'
      end

      describe 'if #source is set' do
        before do
          ha = Response::HashAdapter.new({})
          ha.ancestors = {
            :response_set => ResponseSet::HashAdapter.new('uuid' => 'bar')
          }
          adapter.source = ha
        end

        it "returns its source's response set ID" do
          adapter.response_set_public_id.should == 'bar'
        end
      end
    end

    describe '#pending_prerequisites' do
      describe 'if #source is not set' do
        before do
          adapter.source = nil
        end

        it 'is empty' do
          adapter.pending_prerequisites.should be_empty
        end
      end

      let(:ha) { Response::HashAdapter.new({}) }

      before do
        adapter.source = ha
      end

      it 'returns the answer public ID' do
        ha.answer_id = 'foo'

        adapter.pending_prerequisites[::Answer].should == ['foo']
      end

      it 'returns the question public ID' do
        ha.question_id = 'bar'

        adapter.pending_prerequisites[::Question].should == ['bar']
      end

      it 'returns the response set public ID' do
        hrs = ResponseSet::HashAdapter.new('uuid' => 'baz')
        ha.ancestors = { :response_set => hrs }

        adapter.pending_prerequisites[::ResponseSet].should == ['baz']
      end
    end

    describe '#ensure_prerequisites' do
      let(:ha) { Response::HashAdapter.new({}) }
      let(:map) do
        Field::IdMap.new({
          ::Answer => { 'foo' => 1 },
          ::Question => { 'bar' => 2 },
          ::ResponseSet => { 'baz' => 3 }
        })
      end

      before do
        hrs = ResponseSet::HashAdapter.new('uuid' => 'baz')
        ha.answer_id = 'foo'
        ha.question_id = 'bar'
        ha.ancestors = { :response_set => hrs }

        adapter.source = ha
      end

      it 'fills in #answer_id' do
        adapter.ensure_prerequisites(map)

        resp.answer_id.should == 1
      end

      it 'fills in #question_id' do
        adapter.ensure_prerequisites(map)

        resp.question_id.should == 2
      end

      it 'fills in #response_set_id' do
        adapter.ensure_prerequisites(map)

        resp.response_set_id.should == 3
      end

      it 'returns true if answer_id, question_id, and response_set_id are resolved' do
        adapter.ensure_prerequisites(map).should be_true
      end

      it 'returns false if answer_id is unresolved' do
        ha.answer_id = 'bogus'

        adapter.ensure_prerequisites(map).should be_false
      end

      it 'returns false if question_id is unresolved' do
        ha.question_id = 'bogus'

        adapter.ensure_prerequisites(map).should be_false
      end

      it 'returns false if response_set_id is unresolved' do
        ha.ancestors = nil

        adapter.ensure_prerequisites(map).should be_false
      end
    end
  end
end
