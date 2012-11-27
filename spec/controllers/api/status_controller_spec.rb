require 'spec_helper'

describe Api::StatusController do
  describe '#show' do
    let(:body) { get(:show); JSON.parse(response.body) }

    it 'does not require authentication' do
      get :show

      response.code.should_not == '401'
    end
  end
end
