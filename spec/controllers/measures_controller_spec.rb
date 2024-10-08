# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe MeasuresController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }

  def serialized(subject_measure)
    MeasureSerializer.new(subject_measure).serializable_hash[:data].as_json
  end

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:measure) { FactoryBot.create(:measure, reference: "Published Measure") }
    let!(:archived_measure) { FactoryBot.create(:measure, is_archive: true, reference: "Archived Measure") }
    let!(:draft_measure) { FactoryBot.create(:measure, draft: true, reference: "Draft Measure") }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published measures (no archived or drafts)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(measure)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "guest will see only published measures (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(measure)])
      end

      it "contributor will see all measures" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(measure),
          serialized(archived_measure),
          serialized(draft_measure)
        ])
      end

      it "manager will see all measures" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(measure),
          serialized(archived_measure),
          serialized(draft_measure)
        ])
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }

        it "will not show is_archived items" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"]).to match_array([serialized(measure), serialized(draft_measure)])
        end
      end
    end

    context "filters" do
      let(:category) { FactoryBot.create(:category) }
      let(:measure_different_category) { FactoryBot.create(:measure) }
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:measure_different_recommendation) { FactoryBot.create(:measure) }
      let(:indicator) { FactoryBot.create(:indicator) }
      let(:measure_different_indicator) { FactoryBot.create(:measure) }

      it "filters from category" do
        measure_different_category.categories << category
        subject = get :index, params: {
          category_id: category.id
        }, format: :json
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(measure_different_category.id.to_s)
      end

      it "filters from recommendation" do
        measure_different_recommendation.recommendations << recommendation
        subject = get :index, params: {
          recommendation_id: recommendation.id
        }, format: :json
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(measure_different_recommendation.id.to_s)
      end

      it "filters from indicator" do
        measure_different_indicator.indicators << indicator
        subject = get :index, params: {
          indicator_id: indicator.id
        }, format: :json
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
        expect(json["data"][0]["id"]).to eq(measure_different_indicator.id.to_s)
      end
    end
  end

  describe "Get show" do
    let(:measure) { FactoryBot.create(:measure, reference: "Published Measure") }
    let(:archived_measure) { FactoryBot.create(:measure, draft: true, reference: "Archived Measure") }
    let(:draft_measure) { FactoryBot.create(:measure, draft: true, reference: "Draft Measure") }

    def show(subject_measure)
      get :show, params: {id: subject_measure}, format: :json
    end

    context "when not signed in" do
      it { expect(show(measure)).to be_ok }

      it "shows the published measure" do
        json = JSON.parse(show(measure).body)
        expect(json["data"]).to eq(serialized(measure))
      end

      it "will not show the archived measure" do
        show(archived_measure)
        expect(response).to be_not_found
      end

      it "will not show the draft measure" do
        show(draft_measure)
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a measure" do
        post :create, format: :json, params: {
          measure: {title: "test", description: "test", target_date: "today"}
        }
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:recommendation) { FactoryBot.create(:recommendation) }
      let(:category) { FactoryBot.create(:category) }

      let(:params) {
        {
          measure: {
            description: "test",
            reference: "test reference",
            target_date: "today",
            title: "test"
          }
        }
      }
      subject do
        post :create, format: :json, params:
        # This is an example creating a new recommendation record in the post
        # post :create,
        #      format: :json,
        #      params: {

        #        measure: {
        #          title: 'test',
        #          description: 'test',
        #          target_date: 'today',
        #          recommendation_measures_attributes: [ { recommendation_attributes: { title: 'test 1', number: 1 } } ]
        #        }
        #      }
      end

      it "will not allow a guest to create a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to create a measure" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a measure" do
        sign_in manager
        expect(subject).to be_created
      end

      context "is_archive" do
        let(:params) {
          {
            measure: {
              description: "test",
              is_archive: true,
              reference: "test reference",
              target_date: "today",
              title: "test"
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

      it "will record what manager created the measure", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq manager.id
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {
          measure: {description: "desc only"}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:measure) { FactoryBot.create(:measure) }
    subject do
      put :update,
        format: :json,
        params: {
          id: measure,
          measure: {
            title: "test update",
            description: "test update",
            reference: "test reference update",
            target_date: "today update"
          }
        }
    end

    context "when not signed in" do
      it "not allow updating a measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to update a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to update a measure" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to update a measure" do
        sign_in user
        expect(subject).to be_ok
      end

      it "will reject and update where the last_updated_at is older than updated_at in the database" do
        sign_in user
        measure_get = get :show, params: {id: measure}, format: :json
        json = JSON.parse(measure_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {id: measure,
                     measure: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {id: measure,
                     measure: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}}
          expect(subject).to_not be_ok
        end
      end

      it "will record what manager updated the measure", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq user.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        measure.versions.first.update_column(:whodunnit, contributor.id)
        sign_in user
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(user.id)
      end

      it "will return an error if params are incorrect" do
        sign_in user
        put :update, format: :json, params: {id: measure, measure: {title: ""}}
        expect(response).to have_http_status(422)
      end

      context "when is_archive: true" do
        let(:measure) { FactoryBot.create(:measure, :is_archive) }
        subject do
          put :update,
            format: :json,
            params: {
              id: measure,
              measure: {title: "test update", description: "test update", target_date: "today update"}
            }
        end

        it "can't be updated by manager" do
          sign_in user
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
    let(:measure) { FactoryBot.create(:measure) }
    subject { delete :destroy, format: :json, params: {id: measure} }

    context "when not signed in" do
      it "not allow deleting a measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to delete a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to delete a measure" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to delete a measure" do
        sign_in user
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete a measure" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end
end
