require "swagger_helper"

RSpec.describe "Categories API", type: :request do
  let(:taxonomy) { FactoryBot.create(:taxonomy) }
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:guest) { FactoryBot.create(:user) }

  # Helper to set DeviseTokenAuth headers directly
  def auth_headers_for(user)
    user.create_new_auth_token
  end

  def sign_in_as(user)
    headers = auth_headers_for(user)
    headers.each { |k, v| @request_headers[k] = v }
  end

  # rswag resolves security scheme headers via let variables.
  # Since "access-token" has a hyphen, we use let(:'access-token') which
  # works via RSpec's define_method under the hood.
  # Default to nil for public endpoints.
  let(:"access-token") { nil }
  let(:client) { nil }
  let(:uid) { nil }

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
          # Public access only sees published, non-archived
          expect(json["data"].length).to eq(1)
        end
      end
    end

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

      response "201", "category created" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.dig("data", "attributes", "title")).to eq("New Category")
        end
      end

      response "401", "not authenticated" do
        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid" }

        run_test!
      end

      response "403", "not authorised (insufficient role)" do
        let(:auth) { auth_headers_for(guest) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        run_test!
      end

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
    end
  end

  path "/categories/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Category ID"

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

      response "200", "category updated" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.dig("data", "attributes", "title")).to eq("Updated Title")
        end
      end

      response "401", "not authenticated" do
        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid" }

        run_test!
      end

      response "403", "not authorised (insufficient role)" do
        let(:auth) { auth_headers_for(guest) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        run_test!
      end

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
    end

    delete "Delete a category" do
      tags "Categories"
      security [{access_token: [], client: [], uid: []}]

      response "401", "not authenticated" do
        let(:id) { FactoryBot.create(:category, :published).id }
        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid" }

        run_test!
      end

      response "403", "forbidden - category deletion is disabled" do
        let(:auth) { auth_headers_for(admin) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:id) { FactoryBot.create(:category, :published).id }

        run_test!
      end
    end
  end
end
