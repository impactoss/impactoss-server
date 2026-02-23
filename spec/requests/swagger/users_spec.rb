# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Users API", type: :request do
  include_context "swagger auth helpers"

  # ──────────────────────────────────────────────
  # GET /users
  # ──────────────────────────────────────────────
  path "/users" do
    get "List users" do
      tags "Users"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      include_examples "swagger 401"

      response "200", "returns users (scoped by role)" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        before do
          FactoryBot.create(:user)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"]).not_to be_empty
        end
      end
    end
  end

  # ──────────────────────────────────────────────
  # PUT /users/:id
  # ──────────────────────────────────────────────
  path "/users/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "User ID"

    put "Update a user" do
      tags "Users"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: {type: :string},
              email: {type: :string},
              password: {type: :string},
              password_confirmation: {type: :string}
            }
          }
        }
      }

      include_examples "swagger 401" do
        let(:id) { FactoryBot.create(:user).id }
        let(:user) { {user: {name: "Updated"}} }
      end

      response "200", "user updates own profile" do
        let(:auth) { auth_headers_for(admin) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:id) { admin.id }
        let(:user) { {user: {name: "Updated Name"}} }

        run_test!
      end

      response "200", "admin updates another user" do
        let(:target_user) { FactoryBot.create(:user) }
        let(:auth) { auth_headers_for(admin) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:id) { target_user.id }
        let(:user) { {user: {name: "Admin Updated"}} }

        run_test!
      end

      response "404", "user not found (scoped - guest cannot see other users)" do
        let(:target_user) { FactoryBot.create(:user) }
        let(:auth) { auth_headers_for(guest) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:id) { target_user.id }
        let(:user) { {user: {name: "Should Fail"}} }

        run_test!
      end
    end
  end
end
