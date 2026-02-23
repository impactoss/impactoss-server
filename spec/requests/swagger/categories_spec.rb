# frozen_string_literal: true

require "swagger_helper"

CATEGORY_CREATE_ROLES = Permissions.roles_with_permission("category", "create")
CATEGORY_UPDATE_ROLES = Permissions.roles_with_permission("category", "update")
CATEGORY_DESTROY_ROLES = Permissions.roles_with_permission("category", "destroy")

RSpec.describe "Categories API", type: :request do
  include_context "swagger auth helpers"

  # ──────────────────────────────────────────────
  # GET /categories
  # ──────────────────────────────────────────────
  path "/categories" do
    get "List categories" do
      tags "Categories"
      produces "application/json"

      response "200", "returns published categories" do
        before do
          FactoryBot.create(:category, :published)
          FactoryBot.create(:category, :draft)
          FactoryBot.create(:category, :published, :is_archive)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end

    # ──────────────────────────────────────────────
    # POST /categories
    # ──────────────────────────────────────────────
    post "Create a category" do
      tags "Categories"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              title: {type: :string},
              short_title: {type: :string},
              description: {type: :string},
              target_date: {type: :string},
              taxonomy_id: {type: :integer},
              draft: {type: :boolean}
            },
            required: %w[title taxonomy_id]
          }
        }
      }

      let(:taxonomy) { FactoryBot.create(:taxonomy) }
      let(:category) {
        {
          category: {
            title: "New Category",
            short_title: "New",
            description: "A test category",
            target_date: "2026-12-31",
            taxonomy_id: taxonomy.id
          }
        }
      }

      include_examples "swagger 401"

      if CATEGORY_CREATE_ROLES.any?
        lowest = CATEGORY_CREATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "201", "category created (requires #{lowest}+)" do
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
          let(:category) {
            {category: {description: "missing title", taxonomy_id: 999}}
          }

          run_test!
        end
      else
        include_examples "swagger 403 disabled", "category", "creation"
      end
    end
  end

  # ──────────────────────────────────────────────
  # PUT /categories/:id + DELETE /categories/:id
  # ──────────────────────────────────────────────
  path "/categories/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Category ID"

    # ──────────────────────────────────────────────
    # PUT /categories/:id
    # ──────────────────────────────────────────────
    put "Update a category" do
      tags "Categories"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              title: {type: :string},
              short_title: {type: :string},
              description: {type: :string},
              target_date: {type: :string},
              draft: {type: :boolean},
              is_archive: {type: :boolean},
              manager_id: {type: :integer}
            }
          }
        }
      }

      let(:existing_category) { FactoryBot.create(:category, :published) }
      let(:id) { existing_category.id }
      let(:category) {
        {category: {title: "Updated Title", description: "Updated description"}}
      }

      include_examples "swagger 401"

      if CATEGORY_UPDATE_ROLES.any?
        lowest = CATEGORY_UPDATE_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "200", "category updated (requires #{lowest}+)" do
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
          let(:category) {
            {category: {taxonomy_id: 999}}
          }

          run_test!
        end
      else
        include_examples "swagger 403 disabled", "category", "update"
      end
    end

    # ──────────────────────────────────────────────
    # DELETE /categories/:id
    # ──────────────────────────────────────────────
    delete "Delete a category" do
      tags "Categories"
      security [{access_token: [], client: [], uid: []}]

      let(:id) { FactoryBot.create(:category, :published).id }

      include_examples "swagger 401"

      if CATEGORY_DESTROY_ROLES.any?
        lowest = CATEGORY_DESTROY_ROLES.min_by { |r| Permissions::ROLE_HIERARCHY[r] }

        response "204", "category deleted (requires #{lowest}+)" do
          let(:auth) { auth_headers_for(send(lowest)) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }

          run_test!
        end

        include_examples "swagger 403 forbidden"
      else
        include_examples "swagger 403 disabled", "category", "deletion"
      end
    end
  end
end
