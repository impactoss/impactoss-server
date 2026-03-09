# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Roles API", type: :request do
  path "/roles" do
    get "List roles" do
      tags "Roles"
      produces "application/json"

      response "200", "returns all roles" do
        before do
          FactoryBot.create(:role)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"].length).to eq(1)
        end
      end
    end
  end
end
