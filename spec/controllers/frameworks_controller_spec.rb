require "rails_helper"

RSpec.describe FrameworksController, type: :controller do
  let!(:guest) { FactoryBot.create(:user) }
  let!(:manager) { FactoryBot.create(:user, :manager) }
  let!(:contributor) { FactoryBot.create(:user, :contributor) }

  describe "index" do
    subject { get :index, format: :json }
    let!(:framework) { FactoryBot.create_list(:framework, 3) }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "returns all frameworks" do
        json = JSON.parse(subject.body)
        expect(framework_count(json)).to eq(3)
      end
    end

    context "when signed in" do
      it "returns all frameworks for guest" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(framework_count(json)).to eq(3)
      end

      it "returns all frameworks for contributor" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(framework_count(json)).to eq(3)
      end

      it "returns all frameworks for manager" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(framework_count(json)).to eq(3)
      end
    end
  end

  describe "show" do
    let!(:framework) { FactoryBot.create(:framework) }
    subject { get :show, params: {id: framework.id}, format: :json }

    context "when not signed in" do
      it "returns the expected framework json" do
        expected_json = {"data" =>
          {"id" => framework.id.to_s,
           "type" => "frameworks",
           "attributes" =>
              {"created_at" => framework.created_at.in_time_zone.iso8601,
               "updated_at" => framework.updated_at.in_time_zone.iso8601,
               "title" => framework.title,
               "short_title" => framework.short_title,
               "description" => framework.description,
               "has_indicators" => framework.has_indicators,
               "has_measures" => framework.has_measures,
               "has_response" => framework.has_response}}}

        json = JSON.parse(subject.body)

        expect(json).to eq(expected_json)
      end
    end

    context "when signed in" do
      it "returns the expected framework for guest" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]["id"].to_i).to eq(framework.id)
      end

      it "returns the expected framework for contributor" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"]["id"].to_i).to eq(framework.id)
      end

      it "returns the expected framework for manager" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]["id"].to_i).to eq(framework.id)
      end
    end
  end
end

def framework_count(json)
  json["data"].count { |k| k["type"] == "frameworks" }
end
