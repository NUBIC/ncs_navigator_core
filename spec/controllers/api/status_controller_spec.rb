require 'spec_helper'

describe Api::StatusController do
  describe '#show' do
    let(:body) { get(:show); JSON.parse(response.body) }

    it 'does not require authentication' do
      get :show

      response.code.should == '200'
    end

    describe 'if the database connection is up' do
      it 'returns db = true' do
        body['db'].should be_true
      end

      it 'returns 200' do
        response.code.should == '200'
      end
    end
  end
end
