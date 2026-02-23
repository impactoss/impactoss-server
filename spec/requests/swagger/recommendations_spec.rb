# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Recommendations API", type: :request do
  include_context "swagger auth helpers"

  RECOMMENDATION_CREATE_ROLES = Permissions.roles_with_permission("recommendation", "create")
  RECOMMENDATION_UPDATE_ROLES = Permissions.roles_with_permission("recommendation", "update")
  RECOMMENDATION_DESTROY_ROLES = Permissions.roles_with_permission("recommendation", "destroy")

  # ──────────────────────────────────────────────
  # GET /recommendations
  # ──────────────────────────────────────────────
  path "/recommendations" do
    get "List recommendations" do
      tags "Recommendations"
      produces "application/json"

      parameter name: :category_id, in: :query, type: :integer, required: false, description: "Filter by category"
      parameter name: :measure_id, in: :query, type: :integer, required: false, description: "Filter by measure"
      parameter name: :include_archive, in: :query, type: :string, required: false, description: "Set to 'false' to exclude archived"
      parameter name: :current_only, in: :query, type: :string, required: false, description: "Set to 'true' for current only"

      response "200", "returns published recommendations" do
        before do
          FactoryBot.create(:recommendation, :published)
          FactoryBot.create(:recommendation, :draft)
          FactoryBot.create(:recommendation, :published, :is_archive)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end

    # ──────────────────────────────────────────────
    # POST /recommendations
    # ──────────────────────────────────────────────
    post "Create a recommendation" do
      tags "Recommendations"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :recommendation, in: :body, schema: {
        type: :object,
        properties: {
          recommendation: {
            type: :object,
            properties: {
              title: {type: :string},
              description: {type: :string},
              reference: {type: :string},
              draft: {type: :boolean}
            },
            required: %w[title reference]
          }
        }
      }

      let(:recommendation) {
        {
          recommendation: {
            title: "New Recommendation",
            description: "A test recommendation",
            reference: "REC-001"
          }
        }
      }

      include_examples "swagger 401"

      if RECOMMENDATION_CREATE_ROLES.any?
        lowest = RECOMMENDATION_CREATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "201", "recommendation created (requires #{lowest}+)" do
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
          let(:recommendation) {
            {recommendation: {description: "missing title"}}
          }

          run_test!
        end
      else
        include_examples "swagger 403 disabled", "recommendation", "creation"
      end
    end
  end

  # ──────────────────────────────────────────────
  # PUT /recommendations/:id + DELETE /recommendations/:id
  # ──────────────────────────────────────────────
  path "/recommendations/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Recommendation ID"

    put "Update a recommendation" do
      tags "Recommendations"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :recommendation, in: :body, schema: {
        type: :object,
        properties: {
          recommendation: {
            type: :object,
            properties: {
              title: {type: :string},
              description: {type: :string},
              reference: {type: :string},
              draft: {type: :boolean},
              is_archive: {type: :boolean}
            }
          }
        }
      }

      let(:existing_recommendation) { FactoryBot.create(:recommendation, :published) }
      let(:id) { existing_recommendation.id }
      let(:recommendation) {
        {recommendation: {title: "Updated Title", description: "Updated description"}}
      }

      include_examples "swagger 401"

      if RECOMMENDATION_UPDATE_ROLES.any?
        lowest = RECOMMENDATION_UPDATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "200", "recommendation updated (requires #{lowest}+)" do
          let(:auth) { auth_headers_for(send(lowest)) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }

          run_test!
        end

        include_examples "swagger 403 forbidden"

        response "422", "validation error or optimistic locking conflict" do
          let(:auth) { auth_headers_for(admin) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }
          let(:recommendation) {
            {recommendation: {title: ""}}
          }

          run_test!
        end
      else
        include_examples "swagger 403 disabled", "recommendation", "update"
      end
    end

    delete "Delete a recommendation" do
      tags "Recommendations"
      security [{access_token: [], client: [], uid: []}]

      let(:id) { FactoryBot.create(:recommendation, :published).id }

      include_examples "swagger 401"

      if RECOMMENDATION_DESTROY_ROLES.any?
        lowest = RECOMMENDATION_DESTROY_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "204", "recommendation deleted (requires #{lowest}+)" do
          let(:auth) { auth_headers_for(send(lowest)) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }

          run_test!
        end

        include_examples "swagger 403 forbidden"
      else
        include_examples "swagger 403 disabled", "recommendation", "deletion"
      end
    end
  end
end
