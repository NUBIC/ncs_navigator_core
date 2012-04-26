# -*- coding: utf-8 -*-


# == Schema Information
# Schema version: 20120404205955
#
# Table name: surveys
#
#  id                     :integer         not null, primary key
#  title                  :string(255)
#  description            :text
#  access_code            :string(255)
#  reference_identifier   :string(255)
#  data_export_identifier :string(255)
#  common_namespace       :string(255)
#  common_identifier      :string(255)
#  active_at              :datetime
#  inactive_at            :datetime
#  css_url                :string(255)
#  custom_class           :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  display_order          :integer
#  api_id                 :string(255)
#

require 'spec_helper'

describe Survey do

  context "more than one Survey having the same title", :slow do

    before(:each) do
      Survey.destroy_all
      count = 0
      Dir["#{Rails.root}/spec/fixtures/surveys/*.rb"].sort.each do |f|
        $stdout = StringIO.new
        Surveyor::Parser.parse File.read(f)
        $stdout = STDOUT
        count += 1
      end

      Survey.count.should == count
    end

    it "finds the most recent survey for a given title" do
      title = "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0"
      surveys = Survey.where_title_like(title).all
      surveys.count.should == 2
      Survey.most_recent_for_title(title).should == surveys[0]
    end

    describe "#most_recent_for_access_code" do
      it "finds the most recent survey for a given access code" do
        title = "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0"
        access_code = Survey.to_normalized_string(title)
        Survey.most_recent_for_access_code(access_code).should == Survey.most_recent_for_title(title)
      end
      it "returns nil if code is blank" do
        Survey.most_recent_for_access_code("").should be_nil
      end
    end

    describe "#where_access_code_like" do
      it "returns an empty array if code is blank" do
        Survey.where_access_code_like("").should be_empty
      end
    end

    it 'finds all the most recent surveys' do
      # expected = all survey titles in #{Rails.root}/spec/fixtures/surveys directory
      expected = [
        'INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0 1',
        'INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0'
      ]
      Survey.most_recent_for_each_title.
        collect(&:title).should == expected
    end
  end

  after(:all) do
    Survey.destroy_all
  end

end