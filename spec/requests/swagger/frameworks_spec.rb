# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Frameworks API", type: :request do
  path "/frameworks" do
    get "List frameworks" do
      tags "Frameworks"
      produces "application/json"

      response "200", "returns all frameworks" do
        before do
          FactoryBot.create(:framework)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end
  end
end
