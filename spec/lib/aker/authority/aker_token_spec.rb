# -*- coding: utf-8 -*-

require 'spec_helper'

require 'aker/authority/aker_token'

describe Aker::Authority::AkerToken do
  let(:app) { mock('app') }
  let(:env) { { :request_headers => ::Faraday::Utils::Headers.new } }
  let(:headers) { env[:request_headers] }

  before { app.stub!(:call) }

  describe "static token" do
    subject { Aker::Authority::AkerToken.new(app, 'jo-9') }

    it 'adds the appropriate Authorization header' do
      subject.call(env)
      headers['Authorization'].should == 'CasProxy jo-9'
    end
  end

  describe "dynamic token" do
    subject do
      i = 6
      Aker::Authority::AkerToken.new(app, lambda { i += 2; i ** 2 })
    end

    it 'adds the appropriate Authorization header' do
      subject.call(env)
      headers['Authorization'].should == 'CasProxy 64'
    end

    it 'invokes the lambda for each call' do
      subject.call(env)
      subject.call(env)
      headers['Authorization'].should == 'CasProxy 100'
    end
  end
end