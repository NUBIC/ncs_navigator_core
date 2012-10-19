require 'spec_helper'

require File.expand_path('../../shared/models/a_publicly_identified_record', __FILE__)

describe Question do
  it_should_behave_like 'a publicly identified record' do
    let(:o1) { Factory(:question) }
    let(:o2) { Factory(:question) }
  end
end
