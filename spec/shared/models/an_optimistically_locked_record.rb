require 'spec_helper'

shared_examples_for 'an optimistically locked record' do
  describe 'if it loses an update race' do
    let(:winner) { subject }

    it 'raises StaleObjectError' do
      winner.save!
      loser = subject.class.find(winner.id)

      modify winner, loser
      winner.save!

      lambda { loser.save! }.should raise_error(ActiveRecord::StaleObjectError)
    end
  end
end
