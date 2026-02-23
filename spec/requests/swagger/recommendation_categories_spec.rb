# frozen_string_literal: true

require "swagger_helper"

RECOMMENDATION_CATEGORY_CREATE_ROLES = Permissions.roles_with_permission("recommendation_category", "create")
RECOMMENDATION_CATEGORY_DESTROY_ROLES = Permissions.roles_with_permission("recommendation_category", "destroy")

RSpec.describe "Recommendation Categories API", type: :request do
  include_context "swagger auth helpers"

  # ──────────────────────────────────────────────
  # GET /recommendation_categories
  # ──────────────────────────────────────────────
  path "/recommendation_categories" do
    get "List recommendation categories" do
      tags "Recommendation Categories"
      produces "application/json"

      response "200", "returns all recommendation categories" do
        before do
          FactoryBot.create(:recommendation_category)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end

    # ──────────────────────────────────────────────
    # POST /recommendation_categories
    # ──────────────────────────────────────────────
    post "Create a recommendation category" do
      tags "Recommendation Categories"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :recommendation_category, in: :body, schema: {
        type: :object,
        properties: {
          recommendation_category: {
            type: :object,
            properties: {
              recommendation_id: {type: :integer},
              category_id: {type: :integer}
            },
            required: %w[recommendation_id category_id]
          }
        }
      }

      let(:recommendation_category) {
        {
          recommendation_category: {
            recommendation_id: FactoryBot.create(:recommendation, :published).id,
            category_id: FactoryBot.create(:category, :published).id
          }
        }
      }

      include_examples "swagger 401"

      if RECOMMENDATION_CATEGORY_CREATE_ROLES.any?
        lowest = RECOMMENDATION_CATEGORY_CREATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "201", "recommendation category created (requires #{lowest}+)" do
          let(:auth) { auth_headers_for(send(lowest)) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }

          run_test!
        end

        include_examples "swagger 403 forbidden"

        response "422", "validation error" do
          let(:auth) { auth_headers_for(admin) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }
          let(:recommendation_category) {
            {recommendation_category: {recommendation_id: nil, category_id: nil}}
          }

          run_test!
        end
      else
        include_examples "swagger 403 disabled", "recommendation_category", "creation"
      end
    end
  end

  # ──────────────────────────────────────────────
  # DELETE /recommendation_categories/:id
  # ──────────────────────────────────────────────
  path "/recommendation_categories/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Recommendation Category ID"

    delete "Delete a recommendation category" do
      tags "Recommendation Categories"
      security [{access_token: [], client: [], uid: []}]

      let(:id) { FactoryBot.create(:recommendation_category).id }

      include_examples "swagger 401"

      if RECOMMENDATION_CATEGORY_DESTROY_ROLES.any?
        lowest = RECOMMENDATION_CATEGORY_DESTROY_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "204", "recommendation category deleted (requires #{lowest}+)" do
          let(:auth) { auth_headers_for(send(lowest)) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }

          run_test!
        end

        include_examples "swagger 403 forbidden"
      else
        include_examples "swagger 403 disabled", "recommendation_category", "deletion"
      end
    end
  end
end
