# frozen_string_literal: true

require "swagger_helper"

if Features.enabled?(:measures)
  RSpec.describe "Measures API", type: :request do
    include_context "swagger auth helpers"

    MEASURE_CREATE_ROLES = Permissions.roles_with_permission("measure", "create")
    MEASURE_UDPATE_ROLES = Permissions.roles_with_permission("measure", "update")
    MEASURE_DESTROY_ROLES = Permissions.roles_with_permission("measure", "destroy")

    # ──────────────────────────────────────────────
    # GET /measures
    # ──────────────────────────────────────────────
    path "/measures" do
      get "List measures" do
        tags "Measures"
        produces "application/json"

        parameter name: :category_id, in: :query, type: :integer, required: false, description: "Filter by category"
        parameter name: :recommendation_id, in: :query, type: :integer, required: false, description: "Filter by recommendation"
        parameter name: :indicator_id, in: :query, type: :integer, required: false, description: "Filter by indicator"
        parameter name: :include_archive, in: :query, type: :string, required: false, description: "Set to 'false' to exclude archived"
        parameter name: :current_only, in: :query, type: :string, required: false, description: "Set to 'true' for current only"

        response "200", "returns published measures" do
          before do
            FactoryBot.create(:measure, :published)
            FactoryBot.create(:measure, :draft)
            FactoryBot.create(:measure, :published, :is_archive)
          end

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json["data"].length).to eq(1)
          end
        end
      end

      post "Create a measure" do
        tags "Measures"
        consumes "application/json"
        produces "application/json"
        security [{access_token: [], client: [], uid: []}]

        parameter name: :measure, in: :body, schema: {
          type: :object,
          properties: {
            measure: {
              type: :object,
              properties: {
                title: {type: :string},
                description: {type: :string},
                reference: {type: :string},
                target_date: {type: :string},
                draft: {type: :boolean}
              },
              required: %w[title reference]
            }
          }
        }

        let(:measure) {
          {
            measure: {
              title: "New Measure",
              description: "A test measure",
              reference: "MEA-001",
              target_date: "2026-12-31"
            }
          }
        }

        include_examples "swagger 401"

        if MEASURE_CREATE_ROLES.any?
          lowest = MEASURE_CREATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "201", "measure created (requires #{lowest}+)" do
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
            let(:measure) {
              {measure: {description: "missing title"}}
            }

            run_test!
          end
        else
          include_examples "swagger 403 disabled", "measure", "creation"
        end
      end
    end

    # ──────────────────────────────────────────────
    # PUT /measures/:id + DELETE /measures/:id
    # ──────────────────────────────────────────────
    path "/measures/{id}" do
      parameter name: :id, in: :path, type: :integer, description: "Measure ID"

      put "Update a measure" do
        tags "Measures"
        consumes "application/json"
        produces "application/json"
        security [{access_token: [], client: [], uid: []}]

        parameter name: :measure, in: :body, schema: {
          type: :object,
          properties: {
            measure: {
              type: :object,
              properties: {
                title: {type: :string},
                description: {type: :string},
                reference: {type: :string},
                target_date: {type: :string},
                draft: {type: :boolean},
                is_archive: {type: :boolean}
              }
            }
          }
        }

        let(:existing_measure) { FactoryBot.create(:measure, :published) }
        let(:id) { existing_measure.id }
        let(:measure) {
          {measure: {title: "Updated Title", description: "Updated description"}}
        }

        include_examples "swagger 401"

        if MEASURE_UDPATE_ROLES.any?
          lowest = MEASURE_UDPATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "200", "measure updated (requires #{lowest}+)" do
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
            let(:measure) {
              {measure: {title: ""}}
            }

            run_test!
          end
        else
          include_examples "swagger 403 disabled", "measure", "update"
        end
      end

      delete "Delete a measure" do
        tags "Measures"
        security [{access_token: [], client: [], uid: []}]

        let(:id) { FactoryBot.create(:measure, :published).id }

        include_examples "swagger 401"

        if MEASURE_DESTROY_ROLES.any?
          lowest = MEASURE_DESTROY_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "204", "measure deleted (requires #{lowest}+)" do
            let(:auth) { auth_headers_for(send(lowest)) }
            let(:"access-token") { auth["access-token"] }
            let(:client) { auth["client"] }
            let(:uid) { auth["uid"] }

            run_test!
          end

          include_examples "swagger 403 forbidden"
        else
          include_examples "swagger 403 disabled", "measure", "deletion"
        end
      end
    end
  end
end
