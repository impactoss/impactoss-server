require "rails_helper"
require "json"

RSpec.describe RecommendationRecommendationsController, type: :controller do
  describe "index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }
    end
  end

  describe "show" do
    let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }
    subject { get :show, params: {id: recommendation_recommendation}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "shows the recommendation_recommendation" do
        json = JSON.parse(subject.body)
        expect(json["data"]["id"].to_i).to eq(recommendation_recommendation.id)
      end
    end
  end

  describe "create" do
    context "when not signed in" do
      it "doesnt allow creating a recommendation_recommendation" do
        post :create, format: :json, params: {recommendation_recommendation: {recommendation_id: 1, other_recommendation_id: 2}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:recommendation_1) { FactoryBot.create(:recommendation) }
      let(:recommendation_2) { FactoryBot.create(:recommendation) }

      subject do
        post :create,
          format: :json,
          params: {
            recommendation_recommendation: {
              recommendation_id: recommendation_1,
              other_recommendation_id: recommendation_2
            }
          }
      end

      it "wont allow a guest to create a recommendation_recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "wont allow a contributor to create a recommendation_recommendation" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a recommendation_recommendation" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will allow an admin to create a recommendation_recommendation" do
        sign_in admin
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {recommendation_recommendation: {description: "desc"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }
    subject { delete :destroy, format: :json, params: {id: recommendation_recommendation} }

    context "when not signed in" do
      it "not allow deleting a recommendation_recommendation" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "will not allow a guest to delete a recommendation_recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to delete a recommendation_recommendation" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a recommendation_recommendation" do
        sign_in manager
        expect(subject).to be_no_content
      end

      it "will allow an admin to delete a recommendation_recommendation" do
        sign_in admin
        expect(subject).to be_no_content
      end
    end
  end

  describe "update" do
    let(:recommendation_recommendation) { FactoryBot.create(:recommendation_recommendation) }

    it "doesnt allow updates" do
      expect(put: "recommendation_recommendations/42").not_to be_routable
    end
  end
end
