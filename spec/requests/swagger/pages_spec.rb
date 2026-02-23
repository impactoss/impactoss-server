# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Pages API", type: :request do
  include_context "swagger auth helpers"

  PAGE_CREATE_ROLES = Permissions.roles_with_permission("page", "create")
  PAGE_UPDATE_ROLES = Permissions.roles_with_permission("page", "update")
  PAGE_DESTROY_ROLES = Permissions.roles_with_permission("page", "destroy")

  # ──────────────────────────────────────────────
  # GET /pages
  # ──────────────────────────────────────────────
  path "/pages" do
    get "List pages" do
      tags "Pages"
      produces "application/json"

      parameter name: :include_archive, in: :query, type: :string, required: false, description: "Set to 'false' to exclude archived"

      response "200", "returns published pages" do
        before do
          FactoryBot.create(:page, :published)
          FactoryBot.create(:page, :draft)
          FactoryBot.create(:page, :published, :is_archive)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end

    # ──────────────────────────────────────────────
    # POST /pages
    # ──────────────────────────────────────────────
    post "Create a page" do
      tags "Pages"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :page, in: :body, schema: {
        type: :object,
        properties: {
          page: {
            type: :object,
            properties: {
              title: {type: :string},
              content: {type: :string},
              menu_title: {type: :string},
              draft: {type: :boolean},
              order: {type: :integer}
            },
            required: %w[title]
          }
        }
      }

      let(:page) {
        {
          page: {
            title: "New Page",
            content: "Page content",
            menu_title: "New"
          }
        }
      }

      include_examples "swagger 401"

      if PAGE_CREATE_ROLES.any?
        lowest = PAGE_CREATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "201", "page created (requires #{lowest}+)" do
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
          let(:page) {
            {page: {title: ""}}
          }

          run_test!
        end
      else
        include_examples "swagger 403 disabled", "page", "creation"
      end
    end
  end

  # ──────────────────────────────────────────────
  # PUT /pages/:id + DELETE /pages/:id
  # ──────────────────────────────────────────────
  path "/pages/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Page ID"

    put "Update a page" do
      tags "Pages"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :page, in: :body, schema: {
        type: :object,
        properties: {
          page: {
            type: :object,
            properties: {
              title: {type: :string},
              content: {type: :string},
              menu_title: {type: :string},
              draft: {type: :boolean},
              is_archive: {type: :boolean},
              order: {type: :integer}
            }
          }
        }
      }

      let(:existing_page) { FactoryBot.create(:page, :published) }
      let(:id) { existing_page.id }
      let(:page) {
        {page: {title: "Updated Title", content: "Updated content"}}
      }

      include_examples "swagger 401"

      if PAGE_UPDATE_ROLES.any?
        lowest = PAGE_UPDATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "200", "page updated (requires #{lowest}+)" do
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
          let(:page) {
            {page: {title: ""}}
          }

          run_test!
        end
      else
        include_examples "swagger 403 disabled", "page", "update"
      end
    end

    delete "Delete a page" do
      tags "Pages"
      security [{access_token: [], client: [], uid: []}]

      let(:id) { FactoryBot.create(:page, :published).id }

      include_examples "swagger 401"

      if PAGE_DESTROY_ROLES.any?
        lowest = PAGE_DESTROY_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "204", "page deleted (requires #{lowest}+)" do
          let(:auth) { auth_headers_for(send(lowest)) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }

          run_test!
        end

        include_examples "swagger 403 forbidden"
      else
        include_examples "swagger 403 disabled", "page", "deletion"
      end
    end
  end
end
