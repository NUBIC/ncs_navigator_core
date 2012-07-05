# -*- coding: utf-8 -*-
require 'spec_helper'

describe FieldworkHelper do
  describe '#latest_merge_status' do
    let(:fieldwork) { Factory(:fieldwork) }

    it 'outputs a humanized Fieldwork#latest_merge_status' do
      fieldwork.latest_merge_status = 'conflict'

      helper.latest_merge_status(fieldwork).should == 'Conflict'
    end

    describe 'if Fieldwork#latest_merge_status is nil' do
      before do
        fieldwork.latest_merge_status = nil
      end

      it 'outputs "Waiting for field client"' do
        helper.latest_merge_status(fieldwork).should == 'Waiting for field client'
      end
    end
  end
end
