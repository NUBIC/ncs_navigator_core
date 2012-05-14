require 'spec_helper'

module NcsNavigator::Core::Fieldwork::Adapters
  describe ResponseModelAdapter do
    let(:r) { Response.new }
    subject { ResponseModelAdapter.new(r) }

    describe '#response_set_id=' do
      it 'sets the response set ID of the wrapped response' do
        subject.response_set_id = 1

        r.response_set_id.should == 1
      end
    end
  end
end
