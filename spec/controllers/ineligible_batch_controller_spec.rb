require 'spec_helper'

describe IneligibleBatchesController do

  def valid_attributes
    {
      "provider_id"=>@provider.id,
      "ineligible_batch" => {
        "people_count"=>"5",
        "provider_id"=>@provider.id,
        "pre_screening_status_code"=>"1",
        "sampled_person_code"=>"2",
        "date_first_visit"=>"2013-04-16",
        "provider_intro_outcome_code"=>"4",
      }
    }
  end

  before(:each) do
    login(admin_login)
    @provider = Factory(:provider)
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new IneligibleBatch" do
        expect {
          post :create, valid_attributes
        }.to change(IneligibleBatch, :count).by(1)
      end

      it "redirects to provider" do
        post :create, valid_attributes
        assigns(:provider).should == @provider
        response.should redirect_to(@provider)
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested ineligible_batch" do
      ineligible_batch = Factory(:ineligible_batch,
                                    :provider => @provider)
      expect {
        delete :destroy, { :id => ineligible_batch.to_param,
                           :provider_id => @provider.id }
      }.to change(IneligibleBatch, :count).by(-1)
    end

    it "redirects to provider" do
      ineligible_batch = Factory(:ineligible_batch,
                                    :provider => @provider)
      delete :destroy, { :id => ineligible_batch.to_param,
                         :provider_id => @provider.id }
      response.should redirect_to(@provider)
    end
  end

end
