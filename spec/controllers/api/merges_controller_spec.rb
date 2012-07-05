# -*- coding: utf-8 -*-
require 'spec_helper'

describe Api::MergesController do
  describe '#show' do
    it 'is reachable from GET /api/v1/merges/:uuid' do
      { :get => '/api/v1/merges/abc.json' }.should route_to(:controller => 'api/merges', :action => 'show', :id => 'abc', :format => 'json')
    end
  end
end
