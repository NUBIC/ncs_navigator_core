require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe Birth do
    it_should_behave_like 'a survey title acceptor', '_Birth_' do
      let(:populator) { Birth }
    end
  end
end
