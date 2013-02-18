require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe LowIntensity do
    it_should_behave_like 'a survey title acceptor', '_QUE_LI' do
      let(:populator) { LowIntensity }
    end
  end
end
