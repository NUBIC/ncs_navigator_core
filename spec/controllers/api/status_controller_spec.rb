equire 'spec_helper'

describe Api::StatusController do
  describe '#show' do
    let(:body) { get(:show); JSON.parse(response.body) }

    it 'does not require authentication' do
      get :show

      response.code.should == '200'
    end
  end
end
