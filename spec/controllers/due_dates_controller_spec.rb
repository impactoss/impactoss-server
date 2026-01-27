require "rails_helper"
require "json"

RSpec.describe DueDatesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }
    let!(:due_date) { FactoryBot.create(:due_date) }
    let!(:draft_due_date) { FactoryBot.create(:due_date, draft: true) }

    context "when not signed in" do
      it "no due dates are shown" do
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "guest will not see any due_dates" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end

      it "contributor will see all due_dates" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "manager will see all due_dates" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
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
    let(:contributor_indicator) { FactoryBot.create(:indicator, manager: contributor) }
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
      let(:contributor) { FactoryBot.create(:user, :contributor) }

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

      it "does not allow a contributor to create a due_date even for an indicator they manage" do
        contributor = FactoryBot.create(:user, :contributor)
        contributor_indicator = FactoryBot.create(:indicator, manager: contributor)
        sign_in contributor

        response = post :create,
          format: :json,
          params: {
            due_date: {
              due_date: Time.zone.today.to_s,
              indicator_id: contributor_indicator.id
            }
          }
        expect(response).to be_forbidden
      end
    end
  end

  describe "PUT update" do
    let(:due_date) { FactoryBot.create(:due_date) }
    let(:params) {
      {
        id: due_date,
        due_date: { due_date: 1.year.ago.to_s }
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
    subject { delete :destroy, format: :json, params: { id: due_date } }

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
      'due_date', 'view_all'
  end
end
