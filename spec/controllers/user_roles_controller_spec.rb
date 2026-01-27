require "rails_helper"
require "json"

RSpec.describe UserRolesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    let(:guest) { FactoryBot.create(:user) }

    # Define roles at class level
    def self.allowed_view_all_roles
      @allowed_view_all_roles ||= Permissions.roles_with_permission("user_role", "view_all")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    # Dynamically create 2 users for each role type in the hierarchy
    before do
      Permissions::ROLE_HIERARCHY.keys.each do |role_name|
        2.times { FactoryBot.create(:user, role_name.to_sym) }
      end
    end

    context "when not signed in" do
      it "shows an empty list" do
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end
    end

    context "when signed in" do
      it "does not show anything to guest user (no roles)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(0)
      end

      # Test each role's visibility based on view_all permission
      all_roles.each do |role|
        context "#{role}" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          it "sees appropriate user_roles based on permissions" do
            sign_in user
            json = JSON.parse(subject.body)

            if self.class.allowed_view_all_roles.include?(role)
              # Can see all user roles (2 users per role type + the test user)
              expected_count = (Permissions::ROLE_HIERARCHY.keys.length * 2) + 1
              expect(json["data"].length).to eq(expected_count)
            else
              # Can only see their own user role
              expect(json["data"].length).to eq(1)
            end
          end
        end
      end
    end
  end

  describe "Get show" do
    let(:target_user) { FactoryBot.create(:user, :contributor) }
    let(:target_user_role) { target_user.user_roles.first }

    subject {
      get :show, params: {id: target_user_role.id}, format: :json
    }

    # Define roles at class level
    def self.allowed_view_all_roles
      @allowed_view_all_roles ||= Permissions.roles_with_permission("user_role", "view_all")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it "does not show the user_role" do
        expect(subject).to be_not_found
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest (no roles) cannot see other user's user_role" do
        sign_in guest
        expect(subject).to be_not_found
      end

      # Test viewing their own user_role (should work for all roles)
      all_roles.each do |role|
        it "#{role} can view their own user_role" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user

          response = get :show, params: {id: user.user_roles.first.id}, format: :json
          json = JSON.parse(response.body)
          expect(json.dig("data", "id").to_i).to eq(user.user_roles.first.id)
        end
      end

      # Test viewing another user's user_role (depends on view_all permission)
      all_roles.each do |role|
        context "#{role} viewing another user's user_role" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          # Access directly at class level, not via self.class
          can_view = allowed_view_all_roles.include?(role)

          it "#{can_view ? "can" : "cannot"} see it" do
            sign_in user

            if self.class.allowed_view_all_roles.include?(role)
              json = JSON.parse(subject.body)
              expect(json.dig("data", "id").to_i).to eq(target_user_role.id)
            else
              expect(subject).to be_not_found
            end
          end
        end
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
      @allowed_create_any_roles ||= Permissions.roles_with_permission("user_role", "create_any")
    end

    def self.allowed_create_lower_roles
      @allowed_create_lower_roles ||= Permissions.roles_with_permission("user_role", "create_lower")
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

      it "does not allow manager to assign role to user who already has same/higher role" do
        manager = FactoryBot.create(:user, :manager)
        target_user = FactoryBot.create(:user, :admin) # Already has admin role
        contributor_role_record = FactoryBot.create(:role, :contributor)
        sign_in manager

        response = post :create, format: :json, params: {
          user_role: {
            user_id: target_user.id,
            role_id: contributor_role_record.id
          }
        }
        expect(response).to be_forbidden
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

    subject { delete :destroy, format: :json, params: {id: contributor.user_roles.first} }

    # Define roles at class level
    def self.allowed_destroy_any_roles
      @allowed_destroy_any_roles ||= Permissions.roles_with_permission("user_role", "destroy_any")
    end

    def self.allowed_destroy_lower_roles
      @allowed_destroy_lower_roles ||= Permissions.roles_with_permission("user_role", "destroy_lower")
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
