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
