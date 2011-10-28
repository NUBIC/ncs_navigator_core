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