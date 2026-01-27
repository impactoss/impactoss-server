require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    # Define roles at class level
    def self.allowed_view_all_roles
      @allowed_view_all_roles ||= Permissions.roles_with_permission("user", "view_all")
    end

    def self.allowed_show_email_roles
      @allowed_show_email_roles ||= Permissions.roles_with_permission("user", "show_email")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    # Create sample users before tests
    before do
      Permissions::ROLE_HIERARCHY.keys.each do |role_name|
        2.times { FactoryBot.create(:user, role_name.to_sym) }
      end
    end

    context "when not signed in" do
      it { expect(subject).to be_unauthorized }
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest (no roles) sees only themselves" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(guest.id.to_s)
        expect(json["data"][0]["attributes"]["email"]).to eq(guest.email)
        expect(json["data"][0]["attributes"]["domain"]).to eq(guest.domain)
      end

      # Test each role's visibility based on view_all permission
      all_roles.each do |role|
        context "#{role}" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          it "sees appropriate users based on permissions" do
            sign_in user
            json = JSON.parse(subject.body)

            if self.class.allowed_view_all_roles.include?(role)
              # Can see all users (2 per role type + the test user)
              expected_count = (Permissions::ROLE_HIERARCHY.keys.length * 2) + 1
              expect(json["data"].length).to eq(expected_count)

              # Check email visibility
              user_data = json["data"].find { |d| d["id"] == user.id.to_s }
              expect(user_data["attributes"]["email"]).to eq(user.email) # Always see own email

              # Check another user's email visibility
              other_user_data = json["data"].find { |d| d["id"] != user.id.to_s }
              if self.class.allowed_show_email_roles.include?(role)
                # Can see all emails
                expect(other_user_data["attributes"]["email"]).not_to be_nil
              else
                # Cannot see other users' emails
                expect(other_user_data["attributes"]["email"]).to be_nil
                expect(other_user_data["attributes"]["domain"]).not_to be_nil # But can see domain
              end
            else
              # Can only see themselves
              expect(json["data"].length).to eq(1)
              expect(json["data"][0]["id"]).to eq(user.id.to_s)
              expect(json["data"][0]["attributes"]["email"]).to eq(user.email)
            end
          end
        end
      end
    end
  end

  describe "Get show" do
    let(:target_user) { FactoryBot.create(:user, :contributor) }
    subject { get :show, params: {id: target_user.id}, format: :json }

    # Define roles at class level
    def self.allowed_view_all_roles
      @allowed_view_all_roles ||= Permissions.roles_with_permission("user", "view_all")
    end

    def self.allowed_show_email_roles
      @allowed_show_email_roles ||= Permissions.roles_with_permission("user", "show_email")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it "does not show the user" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest (no roles) cannot see other users" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "guest can see themselves" do
        sign_in guest
        response = get :show, params: {id: guest.id}, format: :json
        json = JSON.parse(response.body)
        expect(json.dig("data", "id").to_i).to eq(guest.id)
        expect(json.dig("data", "attributes", "email")).to eq(guest.email)
        expect(json.dig("data", "attributes", "domain")).to eq(guest.domain)
      end

      # Test viewing their own profile (should work for all roles)
      all_roles.each do |role|
        it "#{role} can view their own profile with email" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user

          response = get :show, params: {id: user.id}, format: :json
          json = JSON.parse(response.body)
          expect(json.dig("data", "id").to_i).to eq(user.id)
          expect(json.dig("data", "attributes", "email")).to eq(user.email)
          expect(json.dig("data", "attributes", "domain")).to eq(user.domain)
        end
      end

      # Test viewing another user's profile (depends on view_all and show_email)
      all_roles.each do |role|
        context "#{role} viewing another user's profile" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          # Compute at class level
          can_view = allowed_view_all_roles.include?(role)

          it "#{can_view ? "can" : "cannot"} see it" do
            sign_in user

            if self.class.allowed_view_all_roles.include?(role)
              json = JSON.parse(subject.body)
              expect(json.dig("data", "id").to_i).to eq(target_user.id)
              expect(json.dig("data", "attributes", "domain")).to eq(target_user.domain)

              # Check email visibility
              if self.class.allowed_show_email_roles.include?(role)
                expect(json.dig("data", "attributes", "email")).to eq(target_user.email)
              else
                expect(json.dig("data", "attributes", "email")).to be_nil
              end
            else
              expect(subject).to be_not_found
            end
          end
        end
      end
    end
  end

  describe "PUT update" do
    let(:target_user) { FactoryBot.create(:user, :contributor) }
    let(:params) {
      {
        id: target_user.id,
        user: {
          email: "test@co.nz",
          password: "testtest",
          name: "Sam"
        }
      }
    }
    subject { put :update, format: :json, params: params }

    # Define roles at class level
    def self.update_self_permission
      @update_self_permission ||= Permissions.allowed_for("user", "update_self")
    end

    def self.update_self_enabled_for_all?
      update_self_permission == true
    end

    def self.update_self_disabled?
      update_self_permission == false ||
        update_self_permission.nil? ||
        (update_self_permission.is_a?(Array) && update_self_permission.empty?)
    end

    def self.update_self_roles
      return [] unless update_self_permission.is_a?(Array)
      update_self_permission
    end

    def self.allowed_update_any_roles
      @allowed_update_any_roles ||= Permissions.roles_with_permission("user", "update_any")
    end

    def self.allowed_update_lower_roles
      @allowed_update_lower_roles ||= Permissions.roles_with_permission("user", "update_lower")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it "does not allow updating a user" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      context "updating self" do
        if update_self_enabled_for_all?
          it "allows any user (including guests) to update themselves" do
            user = FactoryBot.create(:user)
            sign_in user

            response = put :update, format: :json, params: {
              id: user.id,
              user: {name: "Updated Name"}
            }
            expect(response).to be_ok
          end

          all_roles.each do |role|
            it "allows #{role} to update themselves" do
              user = FactoryBot.create(:user, role.to_sym)
              sign_in user

              response = put :update, format: :json, params: {
                id: user.id,
                user: {name: "Updated Name"}
              }
              expect(response).to be_ok
            end
          end
        elsif update_self_disabled?
          it "is disabled for all users (e.g., Azure auth handles user updates)" do
            # Test guest
            sign_in guest
            response = put :update, format: :json, params: {
              id: guest.id,
              user: {name: "Updated Name"}
            }
            expect(response).to be_forbidden

            # Test all roles
            all_roles.each do |role|
              user = FactoryBot.create(:user, role.to_sym)
              sign_in user

              response = put :update, format: :json, params: {
                id: user.id,
                user: {name: "Updated Name"}
              }
              expect(response).to be_forbidden
            end
          end
        elsif update_self_roles.any?
          # Specific roles can update themselves
          update_self_roles.each do |role|
            it "allows #{role} to update themselves" do
              user = FactoryBot.create(:user, role.to_sym)
              sign_in user

              response = put :update, format: :json, params: {
                id: user.id,
                user: {name: "Updated Name"}
              }
              expect(response).to be_ok
            end
          end

          # Roles not in the list cannot update themselves
          forbidden_self_update_roles = all_roles - update_self_roles
          forbidden_self_update_roles.each do |role|
            it "does not allow #{role} to update themselves" do
              user = FactoryBot.create(:user, role.to_sym)
              sign_in user

              response = put :update, format: :json, params: {
                id: user.id,
                user: {name: "Updated Name"}
              }
              expect(response).to be_forbidden
            end
          end

          it "does not allow a guest (no roles) to update themselves" do
            sign_in guest

            response = put :update, format: :json, params: {
              id: guest.id,
              user: {name: "Updated Name"}
            }
            expect(response).to be_forbidden
          end
        end
      end

      context "updating other users" do
        it "does not allow a guest (no roles) to update another user" do
          other_user = FactoryBot.create(:user, :contributor)
          sign_in guest

          response = put :update, format: :json, params: {
            id: other_user.id,
            user: {name: "Updated Name"}
          }
          expect(response).to be_not_found
        end

        # Test update_any permission (admins can update anyone)
        allowed_update_any_roles.each do |role|
          context "#{role} with update_any permission" do
            let(:user) { FactoryBot.create(:user, role.to_sym) }

            Permissions::ROLE_HIERARCHY.keys.each do |target_role|
              it "allows updating #{target_role}" do
                target = FactoryBot.create(:user, target_role.to_sym)
                sign_in user

                response = put :update, format: :json, params: {
                  id: target.id,
                  user: {name: "Updated Name"}
                }
                expect(response).to be_ok
              end
            end
          end
        end

        # Test update_lower permission (managers can update lower-level users)
        allowed_update_lower_roles.each do |role|
          # Skip if this role already has update_any permission
          next if allowed_update_any_roles.include?(role)

          context "#{role} with update_lower permission" do
            let(:user) { FactoryBot.create(:user, role.to_sym) }

            Permissions::ROLE_HIERARCHY.each do |target_role, target_level|
              user_level = Permissions::ROLE_HIERARCHY[role]

              if target_level < user_level
                it "allows updating lower-level #{target_role}" do
                  target = FactoryBot.create(:user, target_role.to_sym)
                  sign_in user

                  response = put :update, format: :json, params: {
                    id: target.id,
                    user: {name: "Updated Name"}
                  }
                  expect(response).to be_ok
                end
              else
                it "does not allow updating same/higher-level #{target_role}" do
                  target = FactoryBot.create(:user, target_role.to_sym)
                  sign_in user

                  response = put :update, format: :json, params: {
                    id: target.id,
                    user: {name: "Updated Name"}
                  }
                  expect(response).to be_forbidden
                end
              end
            end
          end
        end

        # Test roles without update permissions
        roles_without_update = all_roles - allowed_update_any_roles - allowed_update_lower_roles
        allowed_view_all_roles = Permissions.roles_with_permission("user", "view_all")

        roles_without_update.each do |role|
          it "does not allow #{role} to update other users" do
            user = FactoryBot.create(:user, role.to_sym)
            other_user = FactoryBot.create(:user, :contributor)
            sign_in user

            response = put :update, format: :json, params: {
              id: other_user.id,
              user: {name: "Updated Name"}
            }

            # If role can view all users, they see forbidden; otherwise not_found due to scope
            if allowed_view_all_roles.include?(role)
              expect(response).to be_forbidden
            else
              expect(response).to be_not_found
            end
          end
        end
      end
    end
  end

  describe "Delete destroy" do
    let(:target_user) { FactoryBot.create(:user, :contributor) }
    subject { delete :destroy, format: :json, params: {id: target_user} }

    context "when not signed in" do
      it "does not allow deleting a user" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete another user" do
        sign_in guest
        expect(subject).to be_not_found
      end

      it "does not allow any user to delete themselves" do
        user = FactoryBot.create(:user, :contributor)
        sign_in user

        response = delete :destroy, format: :json, params: {id: user.id}
        expect(response).to be_forbidden
      end

      # User deletion is blocked in policy
      it "is blocked for all roles (users cannot be deleted)" do
        Permissions::ROLE_HIERARCHY.keys.each do |role|
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end
end
