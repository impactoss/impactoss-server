# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Taxonomies API", type: :request do
  path "/taxonomies" do
    get "List taxonomies" do
      tags "Taxonomies"
      produces "application/json"

      response "200", "returns all taxonomies" do
        before do
          FactoryBot.create(:taxonomy)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end
  end
end
