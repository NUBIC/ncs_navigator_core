# -*- coding: utf-8 -*-
require 'spec_helper'

describe PbsListsController do
  context "with an authenticated user" do
    before(:each) do
      login(user_login)
    end

    def valid_attributes
      provider = Factory(:provider, :name_practice => "provider")
      {
        :provider_id => provider.id,
        :practice_num =>"666",
        :mos          => "100",
        :stratum      => "stratum",
        :sort_var1    => "1",
        :sort_var2    => "2",
        :sort_var3    => "3",
      }
    end

    describe "GET index" do

      let(:provider1) { Factory(:provider, :name_practice => "provider1") }
      let(:provider2) { Factory(:provider, :name_practice => "provider2") }
      let(:provider3) { Factory(:provider, :name_practice => "provider3") }
      let(:pbs_list1) { Factory(:pbs_list, :provider => provider1, :practice_num => 1) }
      let(:pbs_list2) { Factory(:pbs_list, :provider => provider2, :practice_num => 2) }
      let(:pbs_list3) { Factory(:pbs_list, :provider => provider3, :practice_num => 3) }

      describe "without search parameters" do

        before do
          @pbs_lists = [pbs_list1, pbs_list2, pbs_list3]
        end

        it "assigns all PbsList records as @pbs_lists" do
          get :index
          assigns[:pbs_lists].count.should equal(@pbs_lists.count)
          @pbs_lists.each { |pbs| assigns[:pbs_lists].should include pbs }
        end
      end

    end

    describe "GET new" do
      it "assigns a new pbs_list as @pbs_list" do
        provider = Factory(:provider, :name_practice => "provider")
        get :new, :provider_id => provider.id
        assigns(:pbs_list).should be_a_new(PbsList)
      end
    end

    describe "GET edit" do

      let(:provider) { Factory(:provider, :name_practice => "provider") }
      let(:pbs_list) { Factory(:pbs_list, :provider => provider, :practice_num => 1) }

      it "assigns the requested pbs_list as @pbs_list" do
        get :edit, :id => pbs_list.id
        assigns(:pbs_list).should eq(pbs_list)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request" do
          it "creates a new PbsList" do

            provider = Factory(:provider, :name_practice => "provider")

            expect {
              post :create, :pbs_list => valid_attributes
            }.to change(PbsList, :count).by(1)
          end

          it "assigns a newly created pbs_list as @pbs_list" do
            provider = Factory(:provider, :name_practice => "provider")
            post :create, :pbs_list => valid_attributes
            assigns(:pbs_list).should be_a(PbsList)
            assigns(:pbs_list).should be_persisted
          end

          it "redirects to the edit pbs_list form" do
            provider = Factory(:provider, :name_practice => "provider")
            post :create, :pbs_list => valid_attributes
            response.should redirect_to(edit_pbs_list_path(PbsList.last))
          end
        end

        describe "with json request" do
          it "creates a new PbsList" do
            provider = Factory(:provider, :name_practice => "provider")
            expect {
              post :create, :pbs_list => valid_attributes, :format => 'json'
            }.to change(PbsList, :count).by(1)
          end
        end
      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved pbs_list as @pbs_list" do
            # Trigger the behavior that occurs when invalid params are submitted
            PbsList.any_instance.stub(:save).and_return(false)
            post :create, :pbs_list => {}
            assigns(:pbs_list).should be_a_new(PbsList)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            PbsList.any_instance.stub(:save).and_return(false)
            post :create, :pbs_list => {}
            response.should render_template("new")
          end
        end

      end
    end

    describe "PUT update" do

      let(:pbs_list) { Factory(:pbs_list) }

      describe "with valid params" do
        describe "with html request" do
          it "updates the requested pbs_list" do
            PbsList.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :id => pbs_list.id, :pbs_list => {'these' => 'params'}
          end

          it "assigns the requested pbs_list as @pbs_list" do
            put :update, :id => pbs_list.id, :pbs_list => valid_attributes
            assigns(:pbs_list).should eq(pbs_list)
          end

          it "redirects to the pbs_list" do
            put :update, :id => pbs_list.id, :pbs_list => valid_attributes
            response.should redirect_to(edit_pbs_list_path(pbs_list))
          end
        end

        describe "with json request" do
          it "forms json with updated @pbs_list id" do
            put :update, :id => pbs_list.id, :pbs_list => {}, :format => 'json'
            response.body.should eq pbs_list.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the pbs_list as @pbs_list" do
            PbsList.any_instance.stub(:save).and_return(false)
            put :update, :id => pbs_list.id.to_s, :pbs_list => {}
            assigns(:pbs_list).should eq(pbs_list)
          end

          it "re-renders the 'edit' template" do
            PbsList.any_instance.stub(:save).and_return(false)
            put :update, :id => pbs_list.id.to_s, :pbs_list => {}
            response.should render_template("edit")
          end
        end

      end
    end


    describe "GET recruit_provider" do

      describe "when no provider recruitment event exists" do

        let(:provider) { Factory(:provider, :name_practice => "provider") }
        let(:pbs_list) { Factory(:pbs_list, :provider => provider, :pr_recruitment_start_date => nil) }

        it "creates a new Event with event type provider_recruitment" do
          expect {
            get :recruit_provider, :id => pbs_list.id
          }.to change(Event, :count).by(1)
        end

        describe "updating the Pbs List record" do

          it "sets PR_RECRUITMENT_STATUS to 3 (Provider Recruitment in Progress)" do
            pbs_list.pr_recruitment_status_code.should_not == 3
            get :recruit_provider, :id => pbs_list.id
            PbsList.find(pbs_list.id).pr_recruitment_status_code.should == 3
          end

          it "sets PR_RECRUITMENT_START_DATE to current date" do
            pbs_list.pr_recruitment_start_date.should be_blank
            get :recruit_provider, :id => pbs_list.id
            PbsList.find(pbs_list.id).pr_recruitment_start_date.should == Date.today
          end

        end

        it "redirects to provider_staff_list_path" do
          get :recruit_provider, :id => pbs_list.id
          response.should redirect_to(staff_list_provider_path(provider, :event_id => Event.last))
        end

      end

    end

  end
end
