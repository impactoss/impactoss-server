require "rails_helper"
require "json"

RSpec.describe UserRolesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it "shows an empty list" do
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager_role) { FactoryBot.create(:role, :manager) }
      let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
      let(:manager2) { FactoryBot.create(:user, roles: [manager_role]) }
      let(:contributor_role) { FactoryBot.create(:role, :contributor) }
      let(:contributor) { FactoryBot.create(:user, roles: [contributor_role]) }
      let(:contributor2) { FactoryBot.create(:user, roles: [contributor_role]) }
      let(:admin_role) { FactoryBot.create(:role, :admin) }
      let(:admin) { FactoryBot.create(:user, roles: [admin_role]) }
      let(:admin2) { FactoryBot.create(:user, roles: [admin_role]) }

      it "does not show anything to guest user" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end

      it "shows all users roles for contributors" do
        contributor
        contributor2
        manager
        manager2
        admin
        admin2
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(6)
        returned_roles = json["data"].map { |user_role| user_role["attributes"]["role_id"] }.uniq
        permitted_roles = [contributor.roles.first.id, manager.roles.first.id]
        expect(permitted_roles - returned_roles).to be_empty
      end

      it "shows all users roles for managers" do
        contributor
        contributor2
        manager
        manager2
        admin
        admin2
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(6)
        returned_roles = json["data"].map { |user_role| user_role["attributes"]["role_id"] }.uniq
        permitted_roles = [contributor.roles.first.id, manager.roles.first.id]
        expect(permitted_roles - returned_roles).to be_empty
      end

      it "shows all user roles for admin" do
        contributor
        contributor2
        manager
        manager2
        admin2
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(6)
        returned_roles = json["data"].map { |user_role| user_role["attributes"]["role_id"] }.uniq
        permitted_roles = [contributor.roles.first.id, manager.roles.first.id]
        expect(permitted_roles - returned_roles).to be_empty
      end
    end
  end

  describe "Get show" do
    let(:user_role) { FactoryBot.create(:user_role) }
    subject { get :show, params: {id: user_role}, format: :json }

    context "when not signed in" do
      it "does not show the user_role" do
        expect(subject).to be_not_found
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      subject { get :show, params: {id: contributor.user_roles.first.id}, format: :json }

      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "shows no user_role for guest" do
        sign_in guest
        expect(subject).to be_not_found
      end
      it "shows user_role for contributor" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"]["id"].to_i).to eq(contributor.user_roles.first.id)
      end
      it "shows user_role for manager" do
        sign_in manager
        subject_manager = get :show, params: {id: manager.user_roles.first.id}, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json["data"]["id"].to_i).to eq(manager.user_roles.first.id)
      end
      it "shows user_role for admin" do
        sign_in admin
        subject_manager = get :show, params: {id: admin.user_roles.first.id}, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json["data"]["id"].to_i).to eq(admin.user_roles.first.id)
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a user_role" do
        post :create, format: :json, params: {user_role: {user_id: 1, role_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager_role) { FactoryBot.create(:role, :manager) }
      let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
      let(:contributor_role) { FactoryBot.create(:role, :contributor) }
      let(:contributor) { FactoryBot.create(:user, roles: [contributor_role]) }
      let(:admin_role) { FactoryBot.create(:role, :admin) }
      let(:admin) { FactoryBot.create(:user, roles: [admin_role]) }

      subject do
        post :create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: contributor_role.id
            }
          }
      end

      it "will not allow a guest to create a user_role" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to create a contributor, manager, or admin user_role" do
        sign_in contributor
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: contributor_role.id
            }
          }
        expect(subject).to be_forbidden
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: manager_role.id
            }
          }
        expect(subject).to be_forbidden
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: admin_role.id
            }
          }
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a contributor but not a manager or admin user_role" do
        sign_in manager
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: contributor.id,
              role_id: manager_role.id
            }
          }
        expect(subject).to be_forbidden
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: contributor.id,
              role_id: admin_role.id
            }
          }
        expect(subject).to be_forbidden
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: guest.id,
              role_id: contributor_role.id
            }
          }
        expect(subject).to be_created
      end

      it "will allow an admin to create a manager, contributor, or admin admin user_role" do
        sign_in admin
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: contributor.id,
              role_id: manager_role.id
            }
          }
        expect(subject).to be_created
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: manager.id,
              role_id: contributor_role.id
            }
          }
        expect(subject).to be_created
        subject = post :create,
          format: :json,
          params: {
            user_role: {
              user_id: manager.id,
              role_id: admin_role.id
            }
          }
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in admin
        post :create, format: :json, params: {user_role: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:guest) { FactoryBot.create(:user) }
    let(:manager_role) { FactoryBot.create(:role, :manager) }
    let(:manager) { FactoryBot.create(:user, roles: [manager_role]) }
    let(:manager_role2) { FactoryBot.create(:role, :manager) }
    let(:manager2) { FactoryBot.create(:user, roles: [contributor_role, manager_role2]) }
    let(:contributor_role) { FactoryBot.create(:role, :contributor) }
    let(:contributor_role2) { FactoryBot.create(:role, :contributor) }
    let(:contributor) { FactoryBot.create(:user, roles: [contributor_role]) }
    let(:contributor2) { FactoryBot.create(:user, roles: [contributor_role2]) }
    let(:admin_role) { FactoryBot.create(:role, :admin) }
    let(:admin) { FactoryBot.create(:user, roles: [admin_role, contributor_role]) }

    subject { delete :destroy, format: :json, params: {id: contributor.user_roles.first} }

    context "when not signed in" do
      it "not allow deleting a user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "will not allow a guest to delete a user_role" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "will not allow a contributor to delete a user_role" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a contributor user_role but not for an admin or another manager" do
        sign_in manager
        subject = delete :destroy, format: :json, params: {id: contributor.user_roles.first}
        expect(subject).to be_no_content
        subject = delete :destroy, format: :json, params: {id: manager2.user_roles.find_by(role_id: contributor_role.id)}
        expect(subject).to be_forbidden
        subject = delete :destroy, format: :json, params: {id: admin.user_roles.find_by(role_id: contributor_role.id)}
        expect(subject).to be_forbidden
      end

      it "will allow an admin to delete a manager, contributor, and admin user_role" do
        sign_in admin
        subject = delete :destroy, format: :json, params: {id: manager.user_roles.first}
        expect(subject).to be_no_content
        subject = delete :destroy, format: :json, params: {id: contributor2.user_roles.first}
        expect(subject).to be_no_content
        subject = delete :destroy, format: :json, params: {id: admin.user_roles.first}
        expect(subject).to be_no_content
      end
    end
  end
end
