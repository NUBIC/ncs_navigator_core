require 'spec_helper'

require File.expand_path('../../shared/models/a_publicly_identified_record', __FILE__)

describe Answer do
  it_should_behave_like 'a publicly identified record' do
    let(:o1) { Factory(:answer) }
    let(:o2) { Factory(:answer) }
  end
end
