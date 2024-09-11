# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe IndicatorsController, type: :controller do
  def serialized(subject_indicator)
    IndicatorSerializer.new(subject_indicator).serializable_hash[:data].as_json
  end

  let(:admin) { FactoryBot.create(:user, :admin) }

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:indicator) { FactoryBot.create(:indicator, reference: "Published Indicator") }
    let!(:archived_indicator) { FactoryBot.create(:indicator, is_archive: true, reference: "Archived Indicator") }
    let!(:draft_indicator) { FactoryBot.create(:indicator, draft: true, reference: "Draft Indicator") }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published indicators (no archived or draft)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(indicator)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "guest will see only published indicators (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(indicator)])
      end

      it "contributor will see all indicators" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(indicator),
          serialized(archived_indicator),
          serialized(draft_indicator)
        ])
      end

      it "manager will see all indicators" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(indicator),
          serialized(archived_indicator),
          serialized(draft_indicator)
        ])
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }

        it "will not show is_archived items" do
          sign_in manager
          json = JSON.parse(subject.body)

          expect(json["data"]).to match_array([
            serialized(indicator),
            serialized(draft_indicator)
          ])
        end
      end

      context "when current_only=true" do
        let!(:current_category) { FactoryBot.create(:category, :has_date, taxonomy: reporting_cycle_taxonomy) }
        let!(:non_current_recommendation) { FactoryBot.create(:recommendation) }
        let!(:non_reporting_cycle_recommendation) { FactoryBot.create(:recommendation) }
        let!(:parent_taxonomy) { FactoryBot.create(:taxonomy) }
        let!(:recommendation) { FactoryBot.create(:recommendation) }
        let!(:reporting_cycle_taxonomy) { FactoryBot.create(:taxonomy, title: "reporting_cycle", has_date: true, taxonomy: parent_taxonomy) }
        let!(:non_current_recommendation_measure) do
          FactoryBot.create(:recommendation_measure, measure: non_current_measure, recommendation: non_current_recommendation)
        end
        let!(:non_current_measure) { FactoryBot.create(:measure) }
        let!(:non_current_indicator) { FactoryBot.create(:indicator, reference: "Non-Current Indicator") }
        let!(:non_current_measure_indicator) do
          FactoryBot.create(:measure_indicator, measure: non_current_measure, indicator: non_current_indicator)
        end

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

        it "will only show current indicators" do
          sign_in manager
          json = JSON.parse(subject.body)

          expect(json["data"]).to match_array([
            serialized(indicator),
            serialized(archived_indicator),
            serialized(draft_indicator)
          ])
        end
      end
    end

    context "filters" do
      let(:measure) { FactoryBot.create(:measure) }
      let(:indicator_different_measure) { FactoryBot.create(:indicator) }

      it "filters from measures" do
        indicator_different_measure.measures << measure
        subject = get :index, params: {
          measure_id: measure.id
        }, format: :json
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(indicator_different_measure.id.to_s)
      end
    end
  end

  describe "Get show" do
    let(:indicator) { FactoryBot.create(:indicator, reference: "Published Indicator") }
    let(:archived_indicator) { FactoryBot.create(:indicator, is_archive: true, reference: "Archived Indicator") }
    let(:draft_indicator) { FactoryBot.create(:indicator, draft: true, reference: "Draft Indicator") }

    def show(subject_indicator)
      get :show, params: {id: subject_indicator}, format: :json
    end

    context "when not signed in" do
      it { expect(show(indicator)).to be_ok }

      it "shows the published indicator" do
        json = JSON.parse(show(indicator).body)
        expect(json["data"]).to eq(serialized(indicator))
      end

      it "will not show the archived indicator" do
        show(archived_indicator)
        expect(response).to be_not_found
      end

      it "will not show the draft indicator" do
        show(draft_indicator)
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a indicator" do
        post :create, format: :json, params: {
          indicator: {title: "test", description: "test", target_date: "today"}
        }
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:measure) { FactoryBot.create(:measure) }
      let(:params) {
        {
          indicator: {
            title: "test",
            description: "test",
            target_date: "today"
          }
        }
      }
      subject { post :create, format: :json, params: }

      it "will not allow a guest to create a indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to create a indicator" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a indicator" do
        sign_in manager
        expect(subject).to be_created
      end

      context "is_archive" do
        let(:params) {
          {
            indicator: {
              title: "test",
              description: "test",
              target_date: "today",
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

      it "will record what manager created the indicator", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {indicator: {description: "desc only"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let!(:indicator) { FactoryBot.create(:indicator) }
    subject do
      put :update,
        format: :json,
        params: {id: indicator,
                 indicator: {title: "test update", description: "test update", target_date: "today update"}}
    end

    context "when not signed in" do
      it "not allow updating a indicator" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to update a indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to update a indicator" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a indicator" do
        sign_in manager
        expect(subject).to be_ok
      end

      it "will reject an update where the last_updated_at is older than updated_at in the database" do
        sign_in manager
        indicator_get = get :show, params: {id: indicator}, format: :json
        json = JSON.parse(indicator_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: indicator,
                     indicator: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: indicator,
                     indicator: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the indicator", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq manager.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        indicator.versions.first.update_column(:whodunnit, contributor.id)
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(manager.id)
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        put :update, format: :json, params: {id: indicator, indicator: {title: ""}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:indicator) { FactoryBot.create(:indicator) }
    subject { delete :destroy, format: :json, params: {id: indicator} }

    context "when not signed in" do
      it "not allow deleting a indicator" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to delete a indicator" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to delete a indicator" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to delete a indicator" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete a indicator" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end
end
