require 'spec_helper'

shared_examples_for 'a survey title acceptor' do |*patterns|
  it 'responds to #applies_to?' do
    populator.should respond_to(:applies_to?)
  end

  describe '#applies_to?' do
    patterns.each do |p|
      let(:s) { Factory(:survey, :title => p) }
      let(:rs) { Factory(:response_set, :survey => s) }

      it "returns true if the response set's survey title contains '#{p}'" do
        populator.applies_to?(rs).should be_true
      end
    end
  end
end
