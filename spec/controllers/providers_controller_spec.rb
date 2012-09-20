# -*- coding: utf-8 -*-
require 'spec_helper'

describe ProvidersController do

  context "with an authenticated user" do
    before(:each) do
      login(user_login)
    end

    def valid_attributes
      {
        #  provider_type_code         :integer         not null
        #  provider_type_other        :string(255)
        #  provider_ncs_role_code     :integer         not null
        #  provider_ncs_role_other    :string(255)
        #  practice_info_code         :integer         not null
        #  practice_patient_load_code :integer         not null
        #  practice_size_code         :integer         not null
        #  public_practice_code       :integer         not null
        #  provider_info_source_code  :integer         not null
        #  provider_info_source_other :string(255)
        #  provider_info_date         :date
        #  provider_info_update       :date
        #  provider_comment           :text
        #  list_subsampling_code      :integer
        :name_practice            => "Practice Name",
        :proportion_weeks_sampled => 3,
        :proportion_days_sampled  => 3,
        :sampling_notes           => "sampling notes"
      }
    end

    describe "GET index" do

      let(:provider1) { Factory(:provider, :name_practice => "provider1") }
      let(:provider2) { Factory(:provider, :name_practice => "provider2") }
      let(:provider3) { Factory(:provider, :name_practice => "provider3") }

      describe "without search parameters" do

        before do
          @providers = [provider1, provider2, provider3]
        end

        it "assigns all Provider records as @providers" do
          get :index
          assigns[:providers].count.should equal(@providers.count)
          @providers.each { |provider| assigns[:providers].should include provider }
        end
      end

    end

    describe "GET new" do
      it "assigns a new provider as @provider" do
        get :new
        assigns(:provider).should be_a_new(Provider)
      end
    end

    describe "GET edit" do

      let(:provider) { Factory(:provider, :name_practice => "provider") }

      it "assigns the requested provider as @provider" do
        get :edit, :id => provider.id
        assigns(:provider).should eq(provider)
      end
    end

    describe "GET edit_contact_information" do

      let(:provider) { Factory(:provider, :name_practice => "provider") }

      it "assigns the requested provider as @provider" do
        get :edit_contact_information, :id => provider.id
        assigns(:provider).should eq(provider)
      end

      it "builds an address for the provider if none exists" do
        provider.address.should be_nil
        get :edit_contact_information, :id => provider.id
        assigns(:provider).address.should_not be_nil
      end

      it "builds a phone for the provider if none exists" do
        provider.telephones.should be_blank
        get :edit_contact_information, :id => provider.id
        assigns(:provider).telephones.should_not be_blank
        assigns(:provider).telephones.size.should == 2
        assigns(:provider).telephones.collect {|t| t.phone_type_code}.should include Telephone::WORK_PHONE_CODE
      end

      it "builds a fax for the provider if none exists" do
        provider.telephones.should be_blank
        get :edit_contact_information, :id => provider.id
        assigns(:provider).telephones.should_not be_blank
        assigns(:provider).telephones.size.should == 2
        assigns(:provider).telephones.collect {|t| t.phone_type_code}.should include Telephone::FAX_PHONE_CODE
      end

      it "builds a primary contact for the provider if none exists" do
        provider.staff.should be_empty
        get :edit_contact_information, :id => provider.id
        assigns(:provider).staff.should_not be_empty
      end

      it "builds a primary contact information for the provider contact if none exists" do
        provider.staff.should be_empty
        get :edit_contact_information, :id => provider.id
        assigns(:provider).staff.should_not be_empty
        assigns(:provider).staff.first.emails.should_not be_empty
        assigns(:provider).staff.first.telephones.should_not be_empty
      end

    end

    describe "POST create" do
      describe "with valid params" do
        describe "with html request" do
          it "creates a new Provider" do
            expect {
              post :create, :provider => valid_attributes
            }.to change(Provider, :count).by(1)
          end

          it "assigns a newly created provider as @provider" do
            post :create, :provider => valid_attributes
            assigns(:provider).should be_a(Provider)
            assigns(:provider).should be_persisted
          end

          it "redirects to the edit provider form" do
            provider = Factory(:provider, :name_practice => "provider")
            post :create, :provider => valid_attributes
            response.should redirect_to(edit_provider_path(Provider.last))
          end
        end

        describe "with json request" do
          it "creates a new Provider" do
            provider = Factory(:provider, :name_practice => "provider")
            expect {
              post :create, :provider => valid_attributes, :format => 'json'
            }.to change(Provider, :count).by(1)
          end
        end
      end

      describe "with invalid params" do
        describe "with html request" do
          it "assigns a newly created but unsaved provider as @provider" do
            # Trigger the behavior that occurs when invalid params are submitted
            Provider.any_instance.stub(:save).and_return(false)
            post :create, :provider => {}
            assigns(:provider).should be_a_new(Provider)
          end

          it "re-renders the 'new' template" do
            # Trigger the behavior that occurs when invalid params are submitted
            Provider.any_instance.stub(:save).and_return(false)
            post :create, :provider => {}
            response.should render_template("new")
          end
        end

      end
    end

    describe "PUT update" do

      let(:provider) { Factory(:provider) }

      describe "with valid params" do
        describe "with html request" do
          it "updates the requested provider" do
            Provider.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
            put :update, :id => provider.id, :provider => {'these' => 'params'}
          end

          it "assigns the requested provider as @provider" do
            put :update, :id => provider.id, :provider => valid_attributes
            assigns(:provider).should eq(provider)
          end

          it "redirects to the provider" do
            put :update, :id => provider.id, :provider => valid_attributes
            response.should redirect_to(edit_provider_path(provider))
          end
        end

        describe "with json request" do
          it "forms json with updated @provider id" do
            put :update, :id => provider.id, :provider => {}, :format => 'json'
            response.body.should eq provider.to_json
          end
        end
      end

      describe "with invalid params" do
        describe "html request" do
          it "assigns the provider as @provider" do
            Provider.any_instance.stub(:save).and_return(false)
            put :update, :id => provider.id.to_s, :provider => {}
            assigns(:provider).should eq(provider)
          end

          it "re-renders the 'edit' template" do
            Provider.any_instance.stub(:save).and_return(false)
            put :update, :id => provider.id.to_s, :provider => {}
            response.should render_template("edit")
          end
        end

      end
    end

    describe "GET staff_list" do

      describe "html request" do
        let(:provider) { Factory(:provider) }
        let(:event) { Factory(:event, :event_type_code => 22) }

        describe "without event_id param" do
          it "assigns the requested provider as @provider" do
            get :staff_list, :id => provider.id
            assigns(:provider).should eq(provider)
          end

          it "does not assign @event" do
            get :staff_list, :id => provider.id
            assigns(:event).should be_nil
          end
        end

        describe "with event_id param" do
          it "assigns the requested provider as @provider and event as @event" do
            get :staff_list, :id => provider.id, :event_id => event.id
            assigns(:provider).should eq(provider)
            assigns(:event).should eq(event)
          end

        end
      end
    end

    describe "GET new_staff" do
      let(:provider) { Factory(:provider) }

      it "assigns a new person as @staff" do
        get :new_staff, :id => provider.id
        assigns(:staff).should be_a_new(Person)
      end

      it "assigns the requested provider as @provider" do
        get :new_staff, :id => provider.id
        assigns(:provider).should eq(provider)
      end
    end

    describe "POST create_staff" do
      describe "with valid params" do
        describe "with html request" do

          let(:provider) { Factory(:provider, :name_practice => "provider") }

          it "creates a new Person" do
            expect {
              post :create_staff, :id => provider.id, :person => {:first_name => "A", :last_name => "Z"}
            }.to change(Person, :count).by(1)
          end

          it "creates a new Telephone" do
            expect {
              post :create_staff, :id => provider.id, :person => {:first_name => "A", :last_name => "Z"}, :telephone_number => '3125551212'
            }.to change(Telephone, :count).by(1)
          end

          it "creates a new Email" do
            expect {
              post :create_staff, :id => provider.id, :person => {:first_name => "A", :last_name => "Z"}, :email => 'az@dev.null'
            }.to change(Email, :count).by(1)
          end


          it "assigns a newly created person as @staff" do
            post :create_staff, :id => provider.id, :person => {:first_name => "A", :last_name => "Z"}
            assigns(:staff).should be_a(Person)
            assigns(:staff).should be_persisted
          end

          it "redirects to the staff list provider page" do
            post :create_staff, :id => provider.id, :person => {:first_name => "A", :last_name => "Z"}
            response.should redirect_to(staff_list_provider_path(provider))
          end
        end

      end

    end

    describe "GET edit_staff" do
    end

    describe "PUT update_staff" do
    end

    describe "GET recruited" do

      let(:provider) { Factory(:provider, :name_practice => "provider") }

      it "assigns the requested provider as @provider" do
        get :recruited, :id => provider.id
        assigns(:provider).should eq(provider)
      end

    end

    describe "PUT process_recruited" do

      let(:provider) { Factory(:provider) }
      let(:contact) { Factory(:contact) }

      describe "with valid params" do
        describe "with html request" do

          before(:each) do
            Factory(:pbs_list, :provider => provider)
          end

          it "assigns the requested provider as @provider" do
            put :process_recruited, :id => provider.id, :provider => {}
            assigns(:provider).should eq(provider)
          end

          it "redirects to the pbs_lists index page" do
            put :process_recruited, :id => provider.id, :provider => {}
            response.should redirect_to(pbs_lists_path)
          end

          it "updates the provider pbs_list record" do
            put :process_recruited, :id => provider.id, :contact_id => contact.id, :provider => {}
            provider.pbs_list.pr_recruitment_status_code.should == 1
            provider.pbs_list.pr_recruitment_end_date.should == contact.contact_date_date
          end

        end
      end
    end

    describe "GET refused" do

      let(:provider) { Factory(:provider, :name_practice => "provider") }
      let(:sub) { Factory(:provider, :name_practice => "substitute provider") }

      it "assigns the requested provider as @provider" do
        get :refused, :id => provider.id
        assigns(:provider).should eq(provider)
      end

      it "assigns the requested provider.pbs_list as @pbs_list" do
        pbs_list = Factory(:pbs_list, :provider => provider)
        get :refused, :id => provider.id
        assigns(:pbs_list).should eq(pbs_list)
      end

      it "redirects the user if the pbs_list already has a substitute provider" do
        pbs_list = Factory(:pbs_list, :provider => provider, :substitute_provider => sub)
        get :refused, :id => provider.id
        response.should redirect_to(pbs_lists_path)
      end

    end

    describe "PUT process_refused" do

      let(:provider) { Factory(:provider, :name_practice => "provider") }
      let(:sub) { Factory(:provider, :name_practice => "substitute provider") }

      it "sets the pr_recruitment_end_date on the provider.pbs_list record" do
        pbs_list = Factory(:pbs_list, :provider => provider, :substitute_provider => nil)
        put :process_refused, :id => provider.id
        provider.pbs_list.pr_recruitment_end_date.should == Date.today
      end

      it "sets the pr_recruitment_status to 2 (Not recruited) on the provider.pbs_list record" do
        pbs_list = Factory(:pbs_list, :provider => provider, :substitute_provider => nil)
        put :process_refused, :id => provider.id
        provider.pbs_list.pr_recruitment_status_code.should == 2
      end

      it "sets the substitute_provider to the selected substitute" do
        pbs_list = Factory(:pbs_list, :provider => provider, :substitute_provider => nil)
        put :process_refused, :id => provider.id, :substitute_provider_id => sub.id
        provider.pbs_list.substitute_provider.should == sub
      end

    end

  end

end
