require "rails_helper"
require "json"

RSpec.describe DueDatesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }
    let!(:due_date) { FactoryBot.create(:due_date) }
    let!(:draft_due_date) { FactoryBot.create(:due_date, draft: true) }

    # Define roles at class level
    def self.allowed_view_all_roles
      @allowed_view_all_roles ||= Permissions.roles_with_permission('due_date', 'view_all')
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it "no due_dates are shown" do
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest (no roles) will not see any due_dates" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end

      # Test each role's visibility based on view_all permission
      all_roles.each do |role|
        context "#{role}" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          it "sees appropriate due_dates based on permissions" do
            sign_in user
            json = JSON.parse(subject.body)

            if self.class.allowed_view_all_roles.include?(role)
              # Can see all due dates
              expect(json["data"].length).to eq(2)
            else
              # Cannot see any due dates
              expect(json["data"].length).to eq(0)
            end
          end
        end
      end
    end
  end

  describe "Get show" do
    let(:due_date) { FactoryBot.create(:due_date) }
    let(:draft_due_date) { FactoryBot.create(:due_date, draft: true) }
    subject { get :show, params: {id: due_date}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_not_found }

      it "will not show draft due_date" do
        get :show, params: {id: draft_due_date}, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    let(:indicator) { FactoryBot.create(:indicator) }
    let(:params) {
      {
        due_date: {
          due_date: Time.zone.today.to_s,
          indicator_id: indicator.id
        }
      }
    }
    subject { post :create, format: :json, params: params }

    context "when not signed in" do
      it "does not allow creating a due_date" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a due_date" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      # Due dates are auto-generated - all roles are forbidden from creating them
      it "is blocked for all roles (due dates are auto-generated)" do
        Permissions::ROLE_HIERARCHY.keys.each do |role|
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end

  describe "PUT update" do
    let(:due_date) { FactoryBot.create(:due_date) }
    let(:params) {
      {
        id: due_date,
        due_date: {due_date: 1.year.ago.to_s}
      }
    }
    subject { put :update, format: :json, params: params }

    context "when not signed in" do
      it "does not allow updating a due_date" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to update a due_date" do
        sign_in guest
        expect(subject).to be_not_found
      end

      # Due dates are auto-generated - all roles are forbidden from updating them
      it "is blocked for all roles (due dates are auto-generated)" do
        Permissions::ROLE_HIERARCHY.keys.each do |role|
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end

  describe "Delete destroy" do
    let(:due_date) { FactoryBot.create(:due_date) }
    subject { delete :destroy, format: :json, params: {id: due_date} }

    context "when not signed in" do
      it "does not allow deleting a due_date" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete a due_date" do
        sign_in guest
        expect(subject).to be_not_found
      end

      # Due dates are auto-generated - all roles are forbidden from deleting them
      it "is blocked for all roles (due dates are auto-generated)" do
        Permissions::ROLE_HIERARCHY.keys.each do |role|
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end

  describe "Scope permission system tests" do
    include_examples "all or nothing scope permission system",
      "due_date", "view_all"
  end
end
