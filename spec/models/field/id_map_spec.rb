require 'spec_helper'

module Field
  describe IdMap do
    let(:map) { IdMap.new(hash) }

    describe '#id_for' do
      let(:hash) { {} }

      it 'returns the ID for a model having a given public ID' do
        hash[Person] = { 'foo' => 1 }

        map.id_for(Person, 'foo').should == 1
      end

      it 'returns nil if the model does not exist in the underlying map' do
        map.id_for(Person, 'foo').should be_nil
      end

      it 'returns nil if there is no corresponding ID' do
        hash[Person] = { 'foo' => 1 }

        map.id_for(Person, 'bar').should be_nil
      end
    end
  end
end
