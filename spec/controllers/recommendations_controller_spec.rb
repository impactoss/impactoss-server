# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe RecommendationsController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:recommendation) { FactoryBot.create(:recommendation) }
    let!(:draft_recommendation) { FactoryBot.create(:recommendation, draft: true) }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "all published recommendations (no drafts)" do
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "guest will not see draft recommendations" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
      end

      it "contributor will see draft recommendations" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "manager will see draft recommendations" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }
        let!(:archived) { FactoryBot.create(:recommendation, is_archive: true) }

        it "will not show archived recommendations" do
          sign_in user
          json = JSON.parse(subject.body)
          expect(json["data"].map { _1["id"] }.map(&:to_i).sort)
            .to eq([recommendation.id, draft_recommendation.id].sort)
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
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:draft_recommendation) { FactoryBot.create(:recommendation, draft: true) }
    subject { get :show, params: {id: recommendation}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "shows the recommendation" do
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(recommendation.id)
      end

      it "will not show draft recommendation" do
        get :show, params: {id: draft_recommendation}, format: :json
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a recommendation" do
        post :create, format: :json, params: {
          recommendation: {
            title: "test",
            reference: "1",
            support_level: "noted"
          }
        }
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:category) { FactoryBot.create(:category) }
      let(:support_level) { "supported_in_part" }

      subject do
        post :create,
          format: :json,
          params: {
            recommendation: {
              title: "test",
              reference: "1",
              support_level: support_level
            }
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

      context "when support_level is one of the valid options" do
        let(:support_level) { "supported" }

        it "will set the support_level" do
          sign_in user
          json = JSON.parse(subject.body)
          expect(json.dig("data", "attributes", "support_level")).to eq("supported")
        end
      end

      context "when support_level is not one of the valid options" do
        let(:support_level) { "something_else" }

        it "will return a validation error" do
          sign_in user
          expect(subject).to have_http_status(422)
          json = JSON.parse(subject.body)
          expect(json.dig("support_level")).to include(
            "is not a valid support_level. Valid options: noted, supported_in_part, supported"
          )
        end
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
          recommendation: {
            title: "test update",
            description: "test update",
            target_date: "today update"
          }
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
            params: {
              id: recommendation,
              recommendation: {
                title: "test update",
                description: "test updateeee",
                support_level: "supported",
                target_date: "today update",
                updated_at: current_update_at
              }
            }
          expect(subject).to be_ok
        end

        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {
              id: recommendation,
              recommendation: {
                title: "test update",
                description: "test updatebbbb",
                support_level: "supported_in_part",
                target_date: "today update",
                updated_at: current_update_at
              }
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

      it "will update the support_level if it is one of the valid options" do
        sign_in user
        put :update, format: :json, params: {id: recommendation, recommendation: {support_level: "noted"}}
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "support_level")).to eq("noted")
      end

      it "will return an error if the support_level is not one of the valid options" do
        sign_in user
        put :update, format: :json, params: {id: recommendation, recommendation: {support_level: "something_else"}}
        expect(response).to have_http_status(422)
        expect(response.body).to include("is not a valid support_level")
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
