# == Schema Information
# Schema version: 20111110015749
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
      Dir.foreach("#{Rails.root}/spec/fixtures/surveys") do |f|
        unless File.directory?(f)
          puts "~~~ about to run --> rake surveyor FILE=spec/fixtures/surveys/#{f}"
          `rake surveyor FILE=spec/fixtures/surveys/#{f}` 
          count += 1
        end
      end

      Survey.count.should == count
    end
    
    it "finds the most recent survey for a given title" do
      title = "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0"
      surveys = Survey.where_title_like(title).all
      surveys.count.should == 2      
      Survey.most_recent_for_title(title).should == surveys[0]
    end
    
    it "finds the most recent survey for a given access code" do
      title = "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0"
      access_code = Survey.to_normalized_string(title)
      Survey.most_recent_for_access_code(access_code).should == Survey.most_recent_for_title(title)
    end
    
  end
  
  after(:all) do
    Survey.destroy_all
  end

end
