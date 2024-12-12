require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_unauthorized }
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:manager2) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:contributor2) { FactoryBot.create(:user, :contributor) }
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:admin2) { FactoryBot.create(:user, :admin) }

      it "shows only themselves for guests" do
        contributor2
        manager
        admin
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(guest.id.to_s)
        expect(json["data"][0]["attributes"]["email"]).to eq(guest.email)
        expect(json["data"][0]["attributes"]["domain"]).to eq(guest.domain)
      end

      it "shows only themselves for contributors" do
        contributor
        contributor2
        manager
        manager2
        admin
        admin2
        guest
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(contributor.id.to_s)
        expect(json["data"][0]["attributes"]["email"]).to eq(contributor.email)
      end

      it "shows all users for managers, with only the manager's email" do
        contributor
        contributor2
        manager
        manager2
        admin
        admin2
        guest
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(7)

        contributor_data = json["data"].find { |d| d["id"] == contributor.id.to_s }
        expect(contributor_data["attributes"]["email"]).to be_nil
        expect(contributor_data["attributes"]["domain"]).to eq(contributor.domain)

        contributor2_data = json["data"].find { |d| d["id"] == contributor2.id.to_s }
        expect(contributor2_data["attributes"]["email"]).to be_nil
        expect(contributor2_data["attributes"]["domain"]).to eq(contributor2.domain)

        manager_data = json["data"].find { |d| d["id"] == manager.id.to_s }
        expect(manager_data["attributes"]["email"]).to eq(manager.email)
        expect(manager_data["attributes"]["domain"]).to eq(manager.domain)

        manager2_data = json["data"].find { |d| d["id"] == manager2.id.to_s }
        expect(manager2_data["attributes"]["email"]).to be_nil
        expect(manager2_data["attributes"]["domain"]).to eq(manager2.domain)

        admin_data = json["data"].find { |d| d["id"] == admin.id.to_s }
        expect(admin_data["attributes"]["email"]).to be_nil
        expect(admin_data["attributes"]["domain"]).to eq(admin.domain)

        admin2_data = json["data"].find { |d| d["id"] == admin2.id.to_s }
        expect(admin2_data["attributes"]["email"]).to be_nil
        expect(admin2_data["attributes"]["domain"]).to eq(admin2.domain)

        guest_data = json["data"].find { |d| d["id"] == guest.id.to_s }
        expect(guest_data["attributes"]["email"]).to be_nil
        expect(guest_data["attributes"]["domain"]).to eq(guest.domain)
      end

      it "shows all users for admin, including all email addresses" do
        contributor
        contributor2
        manager
        manager2
        admin2
        guest
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(7)

        contributor_data = json["data"].find { |d| d["id"] == contributor.id.to_s }
        expect(contributor_data["attributes"]["email"]).to eq(contributor.email)
        expect(contributor_data["attributes"]["domain"]).to eq(contributor.domain)

        contributor2_data = json["data"].find { |d| d["id"] == contributor2.id.to_s }
        expect(contributor2_data["attributes"]["email"]).to eq(contributor2.email)
        expect(contributor2_data["attributes"]["domain"]).to eq(contributor2.domain)

        manager_data = json["data"].find { |d| d["id"] == manager.id.to_s }
        expect(manager_data["attributes"]["email"]).to eq(manager.email)
        expect(manager_data["attributes"]["domain"]).to eq(manager.domain)

        manager2_data = json["data"].find { |d| d["id"] == manager2.id.to_s }
        expect(manager2_data["attributes"]["email"]).to eq(manager2.email)
        expect(manager2_data["attributes"]["domain"]).to eq(manager2.domain)

        admin_data = json["data"].find { |d| d["id"] == admin.id.to_s }
        expect(admin_data["attributes"]["email"]).to eq(admin.email)
        expect(admin_data["attributes"]["domain"]).to eq(admin.domain)

        admin2_data = json["data"].find { |d| d["id"] == admin2.id.to_s }
        expect(admin2_data["attributes"]["email"]).to eq(admin2.email)
        expect(admin2_data["attributes"]["domain"]).to eq(admin2.domain)

        guest_data = json["data"].find { |d| d["id"] == guest.id.to_s }
        expect(guest_data["attributes"]["email"]).to eq(guest.email)
        expect(guest_data["attributes"]["domain"]).to eq(guest.domain)
      end
    end
  end

  describe "Get show" do
    let(:user_role) { FactoryBot.create(:user_role) }
    subject {
      get :show, params: {
        id: user_role
      }, format: :json
    }

    context "when not signed in" do
      it "does not show the user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      subject {
        get :show, params: {
          id: contributor.id
        }, format: :json
      }

      it "shows no user for guest" do
        sign_in guest
        expect(subject).to be_not_found
      end
      it "shows user, including email and domain, for contributor" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(contributor.id)
        expect(json.dig("data", "attributes", "email")).to eq(contributor.email)
        expect(json.dig("data", "attributes", "domain")).to eq(contributor.domain)
      end

      it "won't show other user for contributor" do
        sign_in contributor
        subject_manager = get :show, params: {
          id: manager.id
        }, format: :json
        expect(subject_manager).to be_not_found
      end

      it "shows user, including email and domain, for manager" do
        sign_in manager
        subject_manager = get :show, params: {
          id: manager.id
        }, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(manager.id)
        expect(json.dig("data", "attributes", "email")).to eq(manager.email)
        expect(json.dig("data", "attributes", "domain")).to eq(manager.domain)
      end

      it "only shows contributor's email domain for manager" do
        sign_in manager
        subject_contributor = get :show, params: {
          id: contributor.id
        }, format: :json
        json = JSON.parse(subject_contributor.body)
        expect(json.dig("data", "id").to_i).to eq(contributor.id)
        expect(json.dig("data", "attributes", "domain")).to eq(contributor.domain)
        expect(json.dig("data", "attributes", "email")).to be_nil
      end

      it "only shows admin's email domain for manager" do
        sign_in manager
        subject_admin = get :show, params: {
          id: admin.id
        }, format: :json
        json = JSON.parse(subject_admin.body)
        expect(json.dig("data", "id").to_i).to eq(admin.id)
        expect(json.dig("data", "attributes", "domain")).to eq(admin.domain)
        expect(json.dig("data", "attributes", "email")).to be_nil
      end

      it "shows email for manager when viewing themselves" do
        sign_in manager
        subject_manager = get :show, params: {
          id: manager.id
        }, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(manager.id)
        expect(json.dig("data", "attributes", "domain")).to eq(manager.domain)
        expect(json.dig("data", "attributes", "email")).to eq(manager.email)
      end

      it "shows user, including email and domain, for admin when viewing themselves" do
        sign_in admin
        subject_manager = get :show, params: {
          id: admin.id
        }, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(admin.id)
        expect(json.dig("data", "attributes", "email")).to eq(admin.email)
        expect(json.dig("data", "attributes", "domain")).to eq(admin.domain)
      end

      it "shows contributor user, including email and domain, for admin" do
        sign_in admin
        subject_contributor = get :show, params: {
          id: contributor.id
        }, format: :json
        json = JSON.parse(subject_contributor.body)
        expect(json.dig("data", "id").to_i).to eq(contributor.id)
        expect(json.dig("data", "attributes", "email")).to eq(contributor.email)
        expect(json.dig("data", "attributes", "domain")).to eq(contributor.domain)
      end
    end
  end

  describe "PUT update" do
    let(:guest) { FactoryBot.create(:user, :contributor) }
    let(:contributor) { FactoryBot.create(:user, :contributor) }
    let(:manager) { FactoryBot.create(:user, :contributor) }
    let(:contributor2) { FactoryBot.create(:user, :contributor) }
    let(:admin) { FactoryBot.create(:user, :admin) }
    subject do
      put :update,
        format: :json,
        params: {
          id: contributor.id, user: {email: "test@co.nz", password: "testtest", name: "Sam"}
        }
    end

    context "when not signed in" do
      it "not allow updating a user" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:manager2) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "will not allow a user to update another user" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "will not allow a user to update themselves" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will not allow a an manager to update themself, contributors, and guests" do
        sign_in manager
        expect(subject).to be_forbidden
        subject2 = put :update,
          format: :json,
          params: {
            id: guest.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}
          }
        expect(subject2).to be_forbidden
      end
      it "will not allow a an manager to another manager or admin" do
        sign_in manager
        subject2 = put :update,
          format: :json,
          params: {
            id: manager2.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}
          }
        expect(subject2).to be_forbidden
        subject2 = put :update,
          format: :json,
          params: {
            id: admin.id, user: {email: "test@co.guest.nz", password: "testtest", name: "Sam"}
          }
        expect(subject2).to be_forbidden
      end
      it "will not allow an admin to update any user" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end

  describe "Delete destroy" do
    let(:guest) { FactoryBot.create(:user) }
    let(:manager_role) { FactoryBot.create(:role, :manager) }
    let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
    let(:contributor_role) { FactoryBot.create(:role, :contributor) }
    let(:contributor_role2) { FactoryBot.create(:role, :contributor) }
    let(:contributor) { FactoryBot.create(:user, roles: [contributor_role]) }
    let(:contributor2) { FactoryBot.create(:user, roles: [contributor_role2]) }
    let(:admin_role) { FactoryBot.create(:role, :admin) }
    let(:admin) { FactoryBot.create(:user, roles: [admin_role]) }

    subject {
      delete :destroy, format: :json, params: {
        id: guest
      }
    }

    context "when not signed in" do
      it "not allow deleting a user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a user to delete another user" do
        sign_in guest
        subject = delete :destroy, format: :json, params: {
          id: manager.id
        }
        expect(subject).to be_not_found
      end

      it "will not allow a user to delete themselves" do
        sign_in contributor
        subject = delete :destroy, format: :json, params: {
          id: contributor.id
        }
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete another user" do
        sign_in admin
        subject = delete :destroy, format: :json, params: {
          id: manager.id
        }
        expect(subject).to be_forbidden
      end
    end
  end
end
