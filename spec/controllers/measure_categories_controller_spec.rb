require "rails_helper"
require "json"

RSpec.describe MeasureCategoriesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }
    end
  end

  describe "Get show" do
    let(:measure_category) { FactoryBot.create(:measure_category) }
    subject { get :show, params: {id: measure_category}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "shows the measure_category" do
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(measure_category.id)
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a measure_category" do
        post :create, format: :json, params: {
          measure_category: {measure_id: 1, category_id: 1}
        }
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:measure) { FactoryBot.create(:measure) }
      let(:category) { FactoryBot.create(:category) }

      subject do
        post :create,
          format: :json,
          params: {

            measure_category: {
              measure_id: measure.id,
              category_id: category.id
            }
          }
      end

      it "will not allow a guest to create a measure_category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to create a measure_category" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a measure_category" do
        sign_in user
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in user
        post :create, format: :json, params: {
          measure_category: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end

      it "will record what manager created the measure category", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in user
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq user.id
      end
    end
  end

  describe "Delete destroy" do
    let(:measure_category) { FactoryBot.create(:measure_category) }
    subject { delete :destroy, format: :json, params: {id: measure_category} }

    context "when not signed in" do
      it "not allow deleting a measure_category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to delete a measure_category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to delete a measure_category" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a measure_category" do
        sign_in manager
        expect(subject).to be_no_content
      end

      context "when the measure_category does not exist" do
        let(:measure_category) do
          {id: -1}
        end

        it "returns the same response as a successful deletion" do
          sign_in manager
          expect(subject).to be_no_content
        end
      end
    end
  end
end
