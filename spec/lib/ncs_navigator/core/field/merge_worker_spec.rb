# -*- coding: utf-8 -*-


require 'spec_helper'

module NcsNavigator::Core::Field
  describe MergeWorker do
    class Counter
      attr_accessor :invocations

      def initialize
        self.invocations = 0
      end

      def run
        self.invocations += 1

        if invocations == 1
          raise ActiveRecord::StaleObjectError.new(Merge.new, 'create')
        end
      end
    end

    describe '#perform' do
      describe 'if Merge#run raises ActiveRecord::StaleObjectError' do
        let(:counter) { Counter.new }

        before do
          ::Merge.stub!(:find => counter)
        end

        it 'restarts the merge' do
          # the ID is irrelevant because Merge#find is stubbed
          subject.perform('foo')

          counter.invocations.should > 1
        end
      end
    end
  end
end
