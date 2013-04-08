# -*- coding: utf-8 -*-


require 'spec_helper'

describe AppointmentSheetsController do

  describe "GET show" do

    let(:person) { Factory(:person) }
    let(:date) { "2013-04-08" }

    before do
      login(user_login)
    end

    it "instantiates an appointment sheet" do
      get :assignment_sheet, :person => person.id, :date => date
    end

  end
end
