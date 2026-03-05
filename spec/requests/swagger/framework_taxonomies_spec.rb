# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Framework Taxonomies API", type: :request do
  path "/framework_taxonomies" do
    get "List framework taxonomies" do
      tags "Framework Taxonomies"
      produces "application/json"

      response "200", "returns all framework taxonomies links" do
        before do
          FactoryBot.create(:framework_taxonomy)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end
  end
end
