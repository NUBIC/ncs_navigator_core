# -*- coding: utf-8 -*-


require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.stub_with :webmock
  c.default_cassette_options = { :record => :once }
end