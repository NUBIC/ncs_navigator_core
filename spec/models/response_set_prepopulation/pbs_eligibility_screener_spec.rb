require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe PbsEligibilityScreener do
    it_should_behave_like 'a survey title acceptor', '_PBSamplingScreen_' do
      let(:populator) { PbsEligibilityScreener }
    end
  end
end
