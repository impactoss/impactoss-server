require "rails_helper"
require "json"

RSpec.describe RecommendationCategoriesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }
    end
  end

  describe "Get show" do
    let(:recommendation_category) { FactoryBot.create(:recommendation_category) }
    subject { get :show, params: {id: recommendation_category}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "shows the recommendation_category" do
        json = JSON.parse(subject.body)
        expect(json.dig("data", "id").to_i).to eq(recommendation_category.id)
      end
    end
  end

  describe "Post create" do
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:category) { FactoryBot.create(:category) }
    let(:params) {
      {
        recommendation_category: {
          recommendation_id: recommendation.id,
          category_id: category.id
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles at class level - falls back to application permissions
    def self.allowed_create_roles
      @allowed_create_roles ||= Permissions.roles_with_permission("recommendation_category", "create")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_create_roles
      @forbidden_create_roles ||= all_roles - allowed_create_roles
    end

    context "when not signed in" do
      it "does not allow creating a recommendation_category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a recommendation_category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_create_roles.each do |role|
        it "allows #{role} to create a recommendation_category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_created
        end
      end

      forbidden_create_roles.each do |role|
        it "does not allow #{role} to create a recommendation_category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        post :create, format: :json, params: {
          recommendation_category: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end

      it "records what user created the recommendation_category", versioning: true do
        expect(PaperTrail).to be_enabled
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq admin.id
      end
    end
  end

  describe "Delete destroy" do
    let(:recommendation_category) { FactoryBot.create(:recommendation_category) }
    subject { delete :destroy, format: :json, params: {id: recommendation_category} }

    # Define roles at class level - falls back to application permissions
    def self.allowed_destroy_roles
      @allowed_destroy_roles ||= Permissions.roles_with_permission("recommendation_category", "destroy")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_destroy_roles
      @forbidden_destroy_roles ||= all_roles - allowed_destroy_roles
    end

    context "when not signed in" do
      it "does not allow deleting a recommendation_category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete a recommendation_category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_destroy_roles.each do |role|
        it "allows #{role} to delete a recommendation_category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_no_content
        end
      end

      forbidden_destroy_roles.each do |role|
        it "does not allow #{role} to delete a recommendation_category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "when the recommendation_category does not exist" do
        let(:recommendation_category) { {id: -1} }

        it "returns the same response as a successful deletion" do
          admin = FactoryBot.create(:user, :admin)
          sign_in admin
          expect(subject).to be_no_content
        end
      end
    end
  end
end
