# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Bookmarks API", type: :request do
  include_context "swagger auth helpers"

  # ──────────────────────────────────────────────
  # GET /bookmarks
  # ──────────────────────────────────────────────
  path "/bookmarks" do
    get "List bookmarks" do
      tags "Bookmarks"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      include_examples "swagger 401"

      response "200", "returns current user's bookmarks" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        before do
          FactoryBot.create(:bookmark, user: manager)
          FactoryBot.create(:bookmark, user: admin) # should not appear
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end

    # ──────────────────────────────────────────────
    # POST /bookmarks
    # ──────────────────────────────────────────────
    post "Create a bookmark" do
      tags "Bookmarks"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :bookmark, in: :body, schema: {
        type: :object,
        properties: {
          bookmark: {
            type: :object,
            properties: {
              title: {type: :string},
              view: {type: :object}
            },
            required: %w[title view]
          }
        }
      }

      let(:bookmark) {
        {
          bookmark: {
            title: "My Bookmark",
            view: {filters: {draft: true}}
          }
        }
      }

      include_examples "swagger 401"

      response "201", "bookmark created" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        run_test!
      end

      response "422", "validation error" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:bookmark) {
          {bookmark: {title: ""}}
        }

        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # PUT /bookmarks/:id + DELETE /bookmarks/:id
  # ──────────────────────────────────────────────
  path "/bookmarks/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Bookmark ID"

    put "Update a bookmark" do
      tags "Bookmarks"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :bookmark, in: :body, schema: {
        type: :object,
        properties: {
          bookmark: {
            type: :object,
            properties: {
              title: {type: :string},
              view: {type: :object}
            }
          }
        }
      }

      include_examples "swagger 401" do
        let(:id) { FactoryBot.create(:bookmark).id }
        let(:bookmark) { {bookmark: {title: "Updated"}} }
      end

      response "200", "bookmark updated by owner" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:existing_bookmark) { FactoryBot.create(:bookmark, user: manager) }
        let(:id) { existing_bookmark.id }
        new_view = {dolor: "sit amet"}
        let(:bookmark) { {bookmark: {title: "Updated Bookmark", view: new_view}} }

        run_test!
      end
    end

    delete "Delete a bookmark" do
      tags "Bookmarks"
      security [{access_token: [], client: [], uid: []}]

      include_examples "swagger 401" do
        let(:id) { FactoryBot.create(:bookmark).id }
      end

      response "204", "bookmark deleted by owner" do
        let(:auth) { auth_headers_for(manager) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:id) { FactoryBot.create(:bookmark, user: manager).id }

        run_test!
      end
    end
  end
end
