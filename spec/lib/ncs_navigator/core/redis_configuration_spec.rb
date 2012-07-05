# -*- coding: utf-8 -*-
require 'spec_helper'

module NcsNavigator::Core
  describe RedisConfiguration do
    let(:app) {
      Class.new do
        include RedisConfiguration
      end.new
    }

    describe '#redis_url' do
      let (:url) { app.redis_url }

      it 'uses the appropriate defaults' do
        app.redis_options = {}
        url.should == 'redis://127.0.0.1:6379/0'
      end

      it 'uses the port if set' do
        app.redis_options = { :port => 6000 }
        url.should == 'redis://127.0.0.1:6000/0'
      end

      it 'uses the db if set' do
        app.redis_options = { :db => 3 }
        url.should == 'redis://127.0.0.1:6379/3'
      end

      it 'uses the host if set' do
        app.redis_options = { :host => 'ncsdb' }
        url.should == 'redis://ncsdb:6379/0'
      end
    end

    describe '#redis_options' do
      it 'converts string keys to symbols' do
        app.redis_options = { 'host' => 'foo' }
        app.redis_options[:host].should == 'foo'
      end
    end
  end
end
