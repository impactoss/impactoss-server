# frozen_string_literal: true

require "swagger_helper"

REPORTS_CREATE_ROLES = Permissions.roles_with_permission("progress_report", "create")
REPORTS_UPDATE_ROLES = Permissions.roles_with_permission("progress_report", "update")
REPORTS_DESTROY_ROLES = Permissions.roles_with_permission("progress_report", "destroy")

if Features.enabled?(:progress_reports)
  RSpec.describe "Progress Reports API", type: :request do
    include_context "swagger auth helpers"

    # ──────────────────────────────────────────────
    # GET /progress_reports
    # ──────────────────────────────────────────────
    path "/progress_reports" do
      get "List progress reports" do
        tags "Progress Reports"
        produces "application/json"

        parameter name: :include_archive, in: :query, type: :string, required: false, description: "Set to 'false' to exclude archived"
        parameter name: :current_only, in: :query, type: :string, required: false, description: "Set to 'true' for current only"

        response "200", "returns progress reports (draft and archived only visible to authorised roles)" do
          before do
            FactoryBot.create(:progress_report, :published)
            FactoryBot.create(:progress_report, :draft)
            FactoryBot.create(:progress_report, :published, :is_archive)
          end

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json["data"].length).to eq(1)
          end
        end
      end

      # ──────────────────────────────────────────────
      # POST /progress_reports
      # ──────────────────────────────────────────────
      post "Create a progress report" do
        tags "Progress Reports"
        consumes "application/json"
        produces "application/json"
        security [{access_token: [], client: [], uid: []}]

        parameter name: :progress_report, in: :body, schema: {
          type: :object,
          properties: {
            progress_report: {
              type: :object,
              properties: {
                title: {type: :string},
                description: {type: :string},
                document_url: {type: :string},
                document_public: {type: :boolean},
                indicator_id: {type: :integer},
                due_date_id: {type: :integer},
                draft: {type: :boolean}
              },
              required: %w[title indicator_id due_date_id]
            }
          }
        }

        let(:indicator) { FactoryBot.create(:indicator, :published) }
        let(:due_date) { FactoryBot.create(:due_date, indicator: indicator) }
        let(:progress_report) {
          {
            progress_report: {
              title: "New Progress Report",
              description: "A test progress report",
              indicator_id: indicator.id,
              due_date_id: due_date.id
            }
          }
        }

        include_examples "swagger 401"

        if REPORTS_CREATE_ROLES.any?
          lowest = REPORTS_CREATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "201", "progress report created (requires #{lowest}+)" do
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
            let(:progress_report) {
              {progress_report: {description: "missing title"}}
            }

            run_test!
          end
        else
          include_examples "swagger 403 disabled", "progress_report", "creation"
        end
      end
    end

    # ──────────────────────────────────────────────
    # PUT /progress_reports/:id + DELETE /progress_reports/:id
    # ──────────────────────────────────────────────
    path "/progress_reports/{id}" do
      parameter name: :id, in: :path, type: :integer, description: "Progress Report ID"

      put "Update a progress report" do
        tags "Progress Reports"
        consumes "application/json"
        produces "application/json"
        security [{access_token: [], client: [], uid: []}]

        parameter name: :progress_report, in: :body, schema: {
          type: :object,
          properties: {
            progress_report: {
              type: :object,
              properties: {
                title: {type: :string},
                description: {type: :string},
                document_url: {type: :string},
                document_public: {type: :boolean},
                draft: {type: :boolean},
                is_archive: {type: :boolean}
              }
            }
          }
        }

        let(:existing_progress_report) { FactoryBot.create(:progress_report, :published) }
        let(:id) { existing_progress_report.id }
        let(:progress_report) {
          {progress_report: {title: "Updated Title", description: "Updated description"}}
        }

        include_examples "swagger 401"

        if REPORTS_UPDATE_ROLES.any?
          lowest = REPORTS_UPDATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

          response "200", "progress report updated (requires #{lowest}+)" do
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
            let(:progress_report) {
              {progress_report: {title: ""}}
            }

            run_test!
          end
        else
          include_examples "swagger 403 disabled", "progress_report", "update"
        end
      end

      delete "Delete a progress report" do
        tags "Progress Reports"
        security [{access_token: [], client: [], uid: []}]

        let(:id) { FactoryBot.create(:progress_report, :published).id }

        include_examples "swagger 401"
        include_examples "swagger 403 disabled", "progress_report", "deletion"
      end
    end
  end
end
