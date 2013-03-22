require 'spec_helper'

module NcsNavigator::Core
  describe CodeListCache do
    let(:cache) { CodeListCache.new }

    describe '#code_list' do
      let(:a_list_name) { 'CONFIRM_TYPE_CL2' }
      let(:actual) { cache.code_list(a_list_name) }

      it 'provides a list of codes' do
        actual.collect(&:class).uniq.should == [NcsCode]
      end

      it 'provides the right list of codes' do
        actual.collect(&:list_name).uniq.should == [a_list_name]
      end

      it 'provides all the codes that are in the database' do
        actual.collect(&:local_code).sort.should ==
          NcsCode.where(:list_name => a_list_name).collect(&:local_code).sort
      end

      it 'provides all the codes that are in the database in code order' do
        actual.collect(&:local_code).should ==
          NcsCode.where(:list_name => a_list_name).collect(&:local_code).sort
      end

      it 'returns nil for an unknown list' do
        cache.code_list('fooquux').should be_nil
      end

      it 'only queries once per distinct list requested' do
        expect {
          cache.code_list(a_list_name)
          cache.code_list('CONFIRM_TYPE_CL4')
          cache.code_list('CONFIRM_TYPE_CL4')
          cache.code_list(a_list_name)
          cache.code_list('CONFIRM_TYPE_CL21')
        }.to_not execute_more_queries_than(3)
      end
    end

    describe '#code_value' do
      let(:a_list_name) { 'EVENT_TYPE_CL1' }
      let(:actual) { cache.code_value(a_list_name, 7) }

      it 'provides an NcsCode' do
        actual.should be_a NcsCode
      end

      it 'gives an instance for the right list' do
        actual.list_name.should == a_list_name
      end

      it 'gives an instance for the right code' do
        actual.local_code.should == 7
      end

      it 'gives nil for an unknown list' do
        cache.code_value('bar', 1).should be_nil
      end

      it 'gives nil for an unknown code' do
        cache.code_value(a_list_name, -100000).should be_nil
      end

      it 'only queries once per code list' do
        expect {
          cache.code_value('CONFIRM_TYPE_CL3', 1)
          cache.code_value('EVENT_TYPE_CL1', 9)
          cache.code_value('CONFIRM_TYPE_CL4', 2)
          cache.code_value('EVENT_TYPE_CL1', 23)
          cache.code_value('EVENT_TYPE_CL1', 27)
          cache.code_value('EVENT_TYPE_CL1', 29)
        }.to_not execute_more_queries_than(3)
      end
    end

    describe '#reset' do
      it 'triggers a reload of a loaded code list' do
        expect {
          cache.code_list('CONFIRM_TYPE_CL2')
          cache.reset
          cache.code_list('CONFIRM_TYPE_CL2')
        }.to execute_more_queries_than(1)
      end
    end
  end
end
