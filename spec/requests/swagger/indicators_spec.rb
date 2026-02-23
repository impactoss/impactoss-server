# frozen_string_literal: true

require "swagger_helper"

INDICATOR_PAGE_CREATE_ROLES = Permissions.roles_with_permission("indicator", "create")
INDICATOR_UDPATE_ROLES = Permissions.roles_with_permission("indicator", "update")
INDICATOR_DESTROY_ROLES = Permissions.roles_with_permission("indicator", "destroy")

if Features.enabled?(:indicators)
  RSpec.describe "Indicators API", type: :request do
    include_context "swagger auth helpers"

    # ──────────────────────────────────────────────
    # GET /indicators
    # ──────────────────────────────────────────────
    path "/indicators" do
      get "List indicators" do
        tags "Indicators"
        produces "application/json"

        parameter name: :measure_id, in: :query, type: :integer, required: false, description: "Filter by measure"
        parameter name: :include_archive, in: :query, type: :string, required: false, description: "Set to 'false' to exclude archived"
        parameter name: :current_only, in: :query, type: :string, required: false, description: "Set to 'true' for current only"

        response "200", "returns published indicators" do
          before do
            FactoryBot.create(:indicator, :published)
            FactoryBot.create(:indicator, :draft)
            FactoryBot.create(:indicator, :published, :is_archive)
          end

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json["data"].length).to eq(1)
          end
        end
      end

      post "Create an indicator" do
        tags "Indicators"
        consumes "application/json"
        produces "application/json"
        security [{access_token: [], client: [], uid: []}]

        parameter name: :indicator, in: :body, schema: {
          type: :object,
          properties: {
            indicator: {
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

        let(:indicator) {
          {
            indicator: {
              title: "New Indicator",
              description: "A test indicator",
              reference: "IND-001",
              target_date: "2026-12-31"
            }
          }
        }

        include_examples "swagger 401"

        if INDICATOR_PAGE_CREATE_ROLES.any?
          lowest = INDICATOR_PAGE_CREATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "201", "indicator created (requires #{lowest}+)" do
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
            let(:indicator) {
              {indicator: {description: "missing title"}}
            }

            run_test!
          end
        else
          include_examples "swagger 403 disabled", "indicator", "creation"
        end
      end
    end

    # ──────────────────────────────────────────────
    # PUT /indicators/:id + DELETE /indicators/:id
    # ──────────────────────────────────────────────
    path "/indicators/{id}" do
      parameter name: :id, in: :path, type: :integer, description: "Indicator ID"

      put "Update an indicator" do
        tags "Indicators"
        consumes "application/json"
        produces "application/json"
        security [{access_token: [], client: [], uid: []}]

        parameter name: :indicator, in: :body, schema: {
          type: :object,
          properties: {
            indicator: {
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

        let(:existing_indicator) { FactoryBot.create(:indicator, :published) }
        let(:id) { existing_indicator.id }
        let(:indicator) {
          {indicator: {title: "Updated Title", description: "Updated description"}}
        }

        include_examples "swagger 401"

        if INDICATOR_UDPATE_ROLES.any?
          lowest = INDICATOR_UDPATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "200", "indicator updated (requires #{lowest}+)" do
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
            let(:indicator) {
              {indicator: {title: ""}}
            }

            run_test!
          end
        else
          include_examples "swagger 403 disabled", "indicator", "update"
        end
      end

      delete "Delete an indicator" do
        tags "Indicators"
        security [{access_token: [], client: [], uid: []}]

        let(:id) { FactoryBot.create(:indicator, :published).id }

        include_examples "swagger 401"

        if INDICATOR_DESTROY_ROLES.any?
          lowest = INDICATOR_DESTROY_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "204", "indicator deleted (requires #{lowest}+)" do
            let(:auth) { auth_headers_for(send(lowest)) }
            let(:"access-token") { auth["access-token"] }
            let(:client) { auth["client"] }
            let(:uid) { auth["uid"] }

            run_test!
          end

          include_examples "swagger 403 forbidden"
        else
          include_examples "swagger 403 disabled", "indicator", "deletion"
        end
      end
    end
  end
end
