require "rails_helper"
require "json"

RSpec.describe RecommendationMeasuresController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }
    end
  end

  describe "Post create" do
    let(:recommendation) { FactoryBot.create(:recommendation, :published) }
    let(:measure) { FactoryBot.create(:measure, :published) }
    let(:params) {
      {
        recommendation_measure: {
          recommendation_id: recommendation.id,
          measure_id: measure.id
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles at class level - falls back to application permissions
    def self.allowed_create_roles
      @allowed_create_roles ||= Permissions.roles_with_permission("recommendation_measure", "create")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_create_roles
      @forbidden_create_roles ||= all_roles - allowed_create_roles
    end

    context "when not signed in" do
      it "does not allow creating a recommendation_measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a recommendation_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_create_roles.each do |role|
        it "allows #{role} to create a recommendation_measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_created
        end
      end

      forbidden_create_roles.each do |role|
        it "does not allow #{role} to create a recommendation_measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        post :create, format: :json, params: {
          recommendation_measure: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end

      it "records what user created the recommendation_measure", versioning: true do
        expect(PaperTrail).to be_enabled
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq admin.id
      end
    end
  end

  describe "Delete destroy" do
    let(:recommendation_measure) { FactoryBot.create(:recommendation_measure) }
    subject { delete :destroy, format: :json, params: {id: recommendation_measure} }

    # Define roles at class level - falls back to application permissions
    def self.allowed_destroy_roles
      @allowed_destroy_roles ||= Permissions.roles_with_permission("recommendation_measure", "destroy")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_destroy_roles
      @forbidden_destroy_roles ||= all_roles - allowed_destroy_roles
    end

    context "when not signed in" do
      it "does not allow deleting a recommendation_measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete a recommendation_measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_destroy_roles.each do |role|
        it "allows #{role} to delete a recommendation_measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_no_content
        end
      end

      forbidden_destroy_roles.each do |role|
        it "does not allow #{role} to delete a recommendation_measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "when the recommendation_measure does not exist" do
        let(:recommendation_measure) { {id: -1} }

        it "returns the same response as a successful deletion" do
          admin = FactoryBot.create(:user, :admin)
          sign_in admin
          expect(subject).to be_no_content
        end
      end
    end
  end
end
