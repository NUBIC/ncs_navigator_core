require 'spec_helper'

shared_examples_for 'a publicly identified record' do
  let(:klass) { o1.class }

  let(:id1) { 'ecb3921c-2b77-4499-9a6e-8df2a011a29f' }
  let(:id2) { 'dfd27b88-f10d-4407-adf4-500e346b169c' }

  before do
    o1.update_attribute(klass.public_id_field, id1)
    o2.update_attribute(klass.public_id_field, id2)
  end

  describe '.with_public_ids' do
    it 'selects records having the given public IDs' do
      klass.with_public_ids([id1]).should == [o1]
    end
  end

  describe '.public_id_to_id_map' do
    it 'maps public ID => ID' do
      klass.public_id_to_id_map([id1, id2]).should include(id1 => o1.id, id2 => o2.id)
    end
  end
end
