require "rails_helper"
require "json"

RSpec.describe RecommendationMeasuresController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }
    end
  end

  describe "Get show" do
    let(:recommendation_measure) { FactoryBot.create(:recommendation_measure) }
    subject {
      get :show, params: {
        id: recommendation_measure
      }, format: :json
    }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "shows the recommendation_measure" do
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(recommendation_measure.id)
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a recommendation_measure" do
        post :create, format: :json, params: {
          recommendation_measure: {recommendation_id: 1, measure_id: 1}
        }
        expect(response).to be_unauthorized
      end
    end
    context "when signed in" do
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:measure) { FactoryBot.create(:measure) }

      subject do
        post :create,
          format: :json,
          params: {
            recommendation_measure: {
              recommendation_id: recommendation.id,
              measure_id: measure.id
            }
          }
      end

      it "will not allow a guest to create a recommendation_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a recommendation_measure" do
        sign_in user
        expect(subject).to be_created
      end

      it "will not allow a contributor to create a recommendation_measure" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will record what manager created the recommendation_measure", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq user.id
      end

      it "will return an error if params are incorrect" do
        sign_in user
        post :create, format: :json, params: {
          recommendation_measure: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:recommendation_measure) { FactoryBot.create(:recommendation_measure) }
    subject {
      delete :destroy, format: :json, params: {
        id: recommendation_measure
      }
    }

    context "when not signed in" do
      it "not allow deleting a recommendation_measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a recommendation_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a recommendation_measure" do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
