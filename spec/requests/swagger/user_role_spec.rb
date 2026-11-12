# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "User Roles API", type: :request do
  include_context "swagger auth helpers"

  # ──────────────────────────────────────────────
  # GET /user_roles
  # ──────────────────────────────────────────────
  path "/user_roles" do
    get "List user roles" do
      tags "User Roles"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      response "200", "returns user roles (scoped by role, returns empty list for guests)" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        before do
          FactoryBot.create(:user, :contributor)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"]).not_to be_empty
        end
      end
    end

    # ──────────────────────────────────────────────
    # POST /user_roles
    # ──────────────────────────────────────────────
    post "Create a user role" do
      tags "User Roles"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :user_role, in: :body, schema: {
        type: :object,
        properties: {
          current_password: {type: :string},
          user_role: {
            type: :object,
            properties: {
              user_id: {type: :integer},
              role_id: {type: :integer}
            },
            required: %w[user_id role_id]
          }
        }
      }

      let(:target_user) { FactoryBot.create(:user) }
      let(:contributor_role) { FactoryBot.create(:role, :contributor) }
      let(:user_role) {
        {
          user_role: {
            user_id: target_user.id,
            role_id: contributor_role.id
          }
        }
      }

      include_examples "swagger 401"

      response "201", "admin assigns a role" do
        let(:auth) { auth_headers_for(admin) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:user_role) {
          {
            current_password: "SecurePassword123!",
            user_role: {
              user_id: target_user.id,
              role_id: contributor_role.id
            }
          }
        }

        run_test!
      end

      include_examples "swagger 403 forbidden"

      response "422", "validation error" do
        let(:auth) { auth_headers_for(admin) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:user_role) {
          {current_password: "SecurePassword123!", user_role: {user_id: nil, role_id: nil}}
        }

        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # DELETE /user_roles/:id
  # ──────────────────────────────────────────────
  path "/user_roles/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "User Role ID"

    delete "Delete a user role" do
      tags "User Roles"
      security [{access_token: [], client: [], uid: []}]

      # No 204 example: rswag does not send a request body on DELETE, so the
      # re-authentication gate rejects it. Success path is covered in
      # spec/requests/user_roles_require_current_password_spec.rb.
      parameter name: :user_role, in: :body, schema: {
        type: :object,
        properties: {
          current_password: {type: :string}
        },
        required: ["current_password"]
      }

      include_examples "swagger 401" do
        let(:id) { FactoryBot.create(:user, :contributor).user_roles.first.id }
      end

      include_examples "swagger 403 forbidden" do
        let(:id) { FactoryBot.create(:user, :contributor).user_roles.first.id }
      end
    end
  end
end
