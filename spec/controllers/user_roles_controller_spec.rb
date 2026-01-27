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
    subject {
      get :show, params: {
        id: user_role
      }, format: :json
    }

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

      subject {
        get :show, params: {
          id: contributor.user_roles.first.id
        }, format: :json
      }

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
        expect(json.dig("data", "id").to_i).to eq(contributor.user_roles.first.id)
      end
      it "shows user_role for manager" do
        sign_in manager
        subject_manager = get :show, params: {
          id: manager.user_roles.first.id
        }, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(manager.user_roles.first.id)
      end
      it "shows user_role for admin" do
        sign_in admin
        subject_manager = get :show, params: {
          id: admin.user_roles.first.id
        }, format: :json
        json = JSON.parse(subject_manager.body)
        expect(json.dig("data", "id").to_i).to eq(admin.user_roles.first.id)
      end
    end
  end

  describe "Post create" do
    let(:guest) { FactoryBot.create(:user) }
    let(:contributor_role) { FactoryBot.create(:role, :contributor) }
    let(:manager_role) { FactoryBot.create(:role, :manager) }
    let(:admin_role) { FactoryBot.create(:role, :admin) }
    let(:params) {
      {
        user_role: {
          user_id: guest.id,
          role_id: contributor_role.id
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles at class level
    def self.allowed_create_any_roles
      @allowed_create_any_roles ||= Permissions.roles_with_permission('user_role', 'create_any')
    end

    def self.allowed_create_lower_roles
      @allowed_create_lower_roles ||= Permissions.roles_with_permission('user_role', 'create_lower')
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it "does not allow creating a user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      it "does not allow a guest (no roles) to create a user_role" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      # Test create_any permission (admins can create any role)
      allowed_create_any_roles.each do |role|
        context "#{role} with create_any permission" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          Permissions::ROLE_HIERARCHY.keys.each do |target_role|
            it "allows assigning #{target_role} role" do
              target_user = FactoryBot.create(:user)
              target_role_record = FactoryBot.create(:role, target_role.to_sym)
              sign_in user

              response = post :create, format: :json, params: {
                user_role: {
                  user_id: target_user.id,
                  role_id: target_role_record.id
                }
              }
              expect(response).to be_created
            end
          end
        end
      end

      # Test create_lower permission (managers can create lower-level roles)
      allowed_create_lower_roles.each do |role|
        # Skip if this role already has create_any permission
        next if allowed_create_any_roles.include?(role)

        context "#{role} with create_lower permission" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          Permissions::ROLE_HIERARCHY.each do |target_role, target_level|
            user_level = Permissions::ROLE_HIERARCHY[role]

            if target_level < user_level
              it "allows assigning lower-level #{target_role} role" do
                target_user = FactoryBot.create(:user)
                target_role_record = FactoryBot.create(:role, target_role.to_sym)
                sign_in user

                response = post :create, format: :json, params: {
                  user_role: {
                    user_id: target_user.id,
                    role_id: target_role_record.id
                  }
                }
                expect(response).to be_created
              end
            else
              it "does not allow assigning same/higher-level #{target_role} role" do
                target_user = FactoryBot.create(:user)
                target_role_record = FactoryBot.create(:role, target_role.to_sym)
                sign_in user

                response = post :create, format: :json, params: {
                  user_role: {
                    user_id: target_user.id,
                    role_id: target_role_record.id
                  }
                }
                expect(response).to be_forbidden
              end
            end
          end
        end
      end

      # Test roles without create permissions
      roles_without_create = all_roles - allowed_create_any_roles - allowed_create_lower_roles
      roles_without_create.each do |role|
        it "does not allow #{role} to create user_roles" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        post :create, format: :json, params: {
          user_role: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end

      it "records what user created the user_role", versioning: true do
        expect(PaperTrail).to be_enabled
        admin = FactoryBot.create(:user, :admin)
        sign_in admin

        response = post :create, format: :json, params: {
          user_role: {
            user_id: guest.id,
            role_id: admin_role.id
          }
        }
        json = JSON.parse(response.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq admin.id
      end
    end
  end

  describe "Delete destroy" do
    let(:guest) { FactoryBot.create(:user) }
    let(:contributor_role) { FactoryBot.create(:role, :contributor) }
    let(:contributor) { FactoryBot.create(:user, roles: [contributor_role]) }

    subject { delete :destroy, format: :json, params: { id: contributor.user_roles.first } }

    # Define roles at class level
    def self.allowed_destroy_any_roles
      @allowed_destroy_any_roles ||= Permissions.roles_with_permission('user_role', 'destroy_any')
    end

    def self.allowed_destroy_lower_roles
      @allowed_destroy_lower_roles ||= Permissions.roles_with_permission('user_role', 'destroy_lower')
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it "does not allow deleting a user_role" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      it "does not allow a guest (no roles) to delete a user_role" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      # Test destroy_any permission (admins can delete any role)
      allowed_destroy_any_roles.each do |role|
        context "#{role} with destroy_any permission" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          Permissions::ROLE_HIERARCHY.keys.each do |target_role|
            it "allows removing #{target_role} role" do
              target_role_record = FactoryBot.create(:role, target_role.to_sym)
              target_user = FactoryBot.create(:user, roles: [target_role_record])
              sign_in user

              response = delete :destroy, format: :json, params: {
                id: target_user.user_roles.first.id
              }
              expect(response).to be_no_content
            end
          end
        end
      end

      # Test destroy_lower permission (managers can delete lower-level roles)
      allowed_destroy_lower_roles.each do |role|
        # Skip if this role already has destroy_any permission
        next if allowed_destroy_any_roles.include?(role)

        context "#{role} with destroy_lower permission" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          Permissions::ROLE_HIERARCHY.each do |target_role, target_level|
            user_level = Permissions::ROLE_HIERARCHY[role]

            if target_level < user_level
              it "allows removing lower-level #{target_role} role" do
                target_role_record = FactoryBot.create(:role, target_role.to_sym)
                target_user = FactoryBot.create(:user, roles: [target_role_record])
                sign_in user

                response = delete :destroy, format: :json, params: {
                  id: target_user.user_roles.first.id
                }
                expect(response).to be_no_content
              end
            else
              it "does not allow removing same/higher-level #{target_role} role" do
                target_role_record = FactoryBot.create(:role, target_role.to_sym)
                target_user = FactoryBot.create(:user, roles: [target_role_record])
                sign_in user

                response = delete :destroy, format: :json, params: {
                  id: target_user.user_roles.first.id
                }
                expect(response).to be_forbidden
              end
            end
          end
        end
      end

      # Test roles without destroy permissions
      roles_without_destroy = all_roles - allowed_destroy_any_roles - allowed_destroy_lower_roles
      roles_without_destroy.each do |role|
        it "does not allow #{role} to delete user_roles" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end

end
