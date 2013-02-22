# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::LowIntensity do

    context "with the lo i quex" do

      before(:each) do
        @person = Factory(:person)
        @participant = Factory(:participant)
        @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)
        Factory(:ppg_detail, :participant => @participant, :desired_history_date => '2010-01-01')
        # setup verification
        PpgStatusHistory.where(:participant_id => @participant).should have(1).entry

        @ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
        @ppg2 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)

        @survey = create_lo_i_quex_with_prepopulated_ppg_status
        @response_set, @instrument = prepare_instrument(@person, @participant, @survey)

        @participant.ppg_status_histories.reload
        @participant.ppg_status.local_code.should == 2
        @response_set.responses.should be_empty
      end

      it "sets prepopulated_ppg_status" do
        rsp = ResponseSetPopulator::LowIntensity.new(@person, @instrument, @survey)
        rs = rsp.populate
        rs.responses.should_not be_empty
        rs.responses.first.to_s.should == @participant.ppg_status.local_code.to_s
        rs.should == @response_set
      end

    end

  end

end
