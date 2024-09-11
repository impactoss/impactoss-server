# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe RecommendationsController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }

  def serialized(subject_recommendation)
    RecommendationSerializer.new(subject_recommendation).serializable_hash[:data].as_json
  end

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:recommendation) { FactoryBot.create(:recommendation, reference: "Published Recommendation") }
    let!(:archived_recommendation) { FactoryBot.create(:recommendation, is_archive: true, reference: "Archived Recommendation") }
    let!(:draft_recommendation) { FactoryBot.create(:recommendation, draft: true, reference: "Draft Recommendation") }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published recommendations (no archived or draft)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(recommendation)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "guest will see only published recommendations (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(recommendation)])
      end

      it "contributor will see all recommendations" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(recommendation),
          serialized(archived_recommendation),
          serialized(draft_recommendation)
        ])
      end

      it "manager will see all recommendations" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(recommendation),
          serialized(archived_recommendation),
          serialized(draft_recommendation)
        ])
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }

        it "will not show archived recommendations" do
          sign_in user
          json = JSON.parse(subject.body)
          expect(json["data"]).to match_array([serialized(recommendation), serialized(draft_recommendation)])
        end
      end

      context "when current_only=true" do
        let!(:parent_taxonomy) { FactoryBot.create(:taxonomy) }
        let!(:reporting_cycle_taxonomy) { FactoryBot.create(:taxonomy, title: "reporting_cycle", has_date: true, taxonomy: parent_taxonomy) }
        let!(:current_category) { FactoryBot.create(:category, :has_date, taxonomy: reporting_cycle_taxonomy) }
        let!(:non_reporting_cycle_recommendation) { FactoryBot.create(:recommendation, reference: "Non-Reporting-Cycle Recommendation") }
        let!(:non_current_recommendation) { FactoryBot.create(:recommendation, reference: "Non-Current Recommendation") }

        before do
          allow(Taxonomy).to receive(:current_reporting_cycle_id).and_return(reporting_cycle_taxonomy.id)
          parent_category = FactoryBot.create(:category, taxonomy: parent_taxonomy)
          non_current_category = FactoryBot.create(:category, :has_date, taxonomy: reporting_cycle_taxonomy, date: current_category.date - 1.day)
          current_category.category = parent_category
          recommendation.categories = [parent_category, current_category]
          non_reporting_cycle_recommendation.categories = [parent_category]
          non_current_recommendation.categories = [non_current_category]
        end

        subject { get :index, format: :json, params: {current_only: true} }

        it "will only show current recommendations" do
          sign_in user
          json = JSON.parse(subject.body)
          expect(json["data"]).to match_array([
            serialized(recommendation),
            serialized(archived_recommendation),
            serialized(draft_recommendation),
            serialized(non_reporting_cycle_recommendation)
          ])
        end
      end
    end

    context "filters" do
      let(:category) { FactoryBot.create(:category) }
      let(:recommendation_different_category) { FactoryBot.create(:recommendation) }
      let(:measure) { FactoryBot.create(:measure) }
      let(:recommendation_different_measure) { FactoryBot.create(:recommendation) }

      it "filters from category" do
        recommendation_different_category.categories << category
        subject = get :index, params: {category_id: category.id}, format: :json
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(recommendation_different_category.id.to_s)
      end

      it "filters from measure" do
        recommendation_different_measure.measures << measure
        subject = get :index, params: {measure_id: measure.id}, format: :json
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(recommendation_different_measure.id.to_s)
      end
    end
  end

  describe "Get show" do
    let(:recommendation) { FactoryBot.create(:recommendation, reference: "Published Recommendation") }
    let(:archived_recommendation) { FactoryBot.create(:recommendation, is_archive: true, reference: "Archived Recommendation") }
    let(:draft_recommendation) { FactoryBot.create(:recommendation, draft: true, reference: "Draft Recommendation") }

    def show(subject_recommendation)
      get :show, params: {id: subject_recommendation}, format: :json
    end

    context "when not signed in" do
      it { expect(show(recommendation)).to be_ok }

      it "shows the published recommendation" do
        json = JSON.parse(show(recommendation).body)
        expect(json.dig("data", "id").to_i).to eq(recommendation.id)
      end

      it "will not show the archived recommendation" do
        show(archived_recommendation)
        expect(response).to be_not_found
      end

      it "will not show the draft recommendation" do
        show(draft_recommendation)
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a recommendation" do
        post :create, format: :json, params: {recommendation: {title: "test", reference: "1"}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:category) { FactoryBot.create(:category) }
      let(:params) {
        {
          recommendation: {
            title: "test",
            reference: "1"
          }
        }
      }
      subject { post :create, format: :json, params: }

      it "will not allow a guest to create a recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to create a recommendation" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a recommendation" do
        sign_in manager
        expect(subject).to be_created
      end

      context "is_archive" do
        let(:params) {
          {
            recommendation: {
              title: "test",
              reference: "1",
              is_archive: true
            }
          }
        }

        it "can't be set by manager" do
          sign_in manager
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq false
        end

        it "can be set by admin" do
          sign_in admin
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq true
        end
      end

      it "will record what manager created the recommendation", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {recommendation: {description: "desc only"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:recommendation) { FactoryBot.create(:recommendation) }
    subject do
      put :update,
        format: :json,
        params: {
          id: recommendation,
          recommendation: {title: "test update", description: "test update", target_date: "today update"}
        }
    end

    context "when not signed in" do
      it "not allow updating a recommendation" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to update a recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to update a recommendation" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a recommendation" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will reject an update where the last_updated_at is older than updated_at in the database" do
        sign_in manager
        recommendation_get = get :show, params: {id: recommendation}, format: :json
        json = JSON.parse(recommendation_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params:
            {
              id: recommendation,
              recommendation: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}
            }
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {
              id: recommendation,
              recommendation: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}
            }
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the recommendation", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        recommendation.versions.first.update_column(:whodunnit, contributor.id)
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(manager.id)
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        put :update, format: :json, params: {id: recommendation, recommendation: {title: ""}}
        expect(response).to have_http_status(422)
      end

      context "when is_archive: true" do
        let(:recommendation) { FactoryBot.create(:recommendation, :is_archive) }

        it "can't be updated by manager" do
          sign_in manager
          expect(subject).not_to be_ok
        end

        it "can be updated by admin" do
          sign_in admin
          expect(subject).to be_ok
        end
      end
    end
  end

  describe "Delete destroy" do
    let(:recommendation) { FactoryBot.create(:recommendation) }
    subject { delete :destroy, format: :json, params: {id: recommendation} }

    context "when not signed in" do
      it "not allow deleting a recommendation" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to delete a recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to delete a recommendation" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to delete a recommendation" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete a recommendation" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end
end
