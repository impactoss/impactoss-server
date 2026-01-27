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

    # Define roles at class level
    def self.allowed_view_archived_roles
      @allowed_view_archived_roles ||= Permissions.roles_with_permission("recommendation", "view_archived")
    end

    def self.allowed_view_draft_roles
      @allowed_view_draft_roles ||= Permissions.roles_with_permission("recommendation", "view_draft")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published recommendations (no archived or draft)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(recommendation)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest will see only published recommendations (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(recommendation)])
      end

      # Test each role's visibility based on permissions
      all_roles.each do |role|
        context "#{role}" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          it "sees appropriate recommendations based on permissions" do
            sign_in user
            json = JSON.parse(subject.body)

            expected_recommendations = [recommendation] # Everyone sees published

            # Add archived if role has view_archived permission
            if self.class.allowed_view_archived_roles.include?(role)
              expected_recommendations << archived_recommendation
            end

            # Add draft if role has view_draft permission
            if self.class.allowed_view_draft_roles.include?(role)
              expected_recommendations << draft_recommendation
            end

            expect(json["data"]).to match_array(expected_recommendations.map { |r| serialized(r) })
          end
        end
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }
        let(:admin) { FactoryBot.create(:user, :admin) }

        it "will not show archived recommendations" do
          sign_in admin
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
        let(:admin) { FactoryBot.create(:user, :admin) }

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
          sign_in admin
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
    let(:category) { FactoryBot.create(:category) }
    let(:params) {
      {
        recommendation: {
          title: "test",
          reference: "1"
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles once at the top of the describe block
    def self.allowed_create_roles
      @allowed_create_roles ||= Permissions.roles_with_permission("recommendation", "create")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_create_roles
      @forbidden_create_roles ||= all_roles - allowed_create_roles
    end

    def self.allowed_modify_archive_roles
      @allowed_modify_archive_roles ||= Permissions.roles_with_permission("recommendation", "modify_is_archive")
    end

    def self.forbidden_modify_archive_roles
      @forbidden_modify_archive_roles ||= all_roles - allowed_modify_archive_roles
    end

    context "when not signed in" do
      it "does not allow creating a recommendation" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_create_roles.each do |role|
        it "allows #{role} to create a recommendation" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_created
        end
      end

      forbidden_create_roles.each do |role|
        it "does not allow #{role} to create a recommendation" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "is_archive attribute" do
        let(:params_with_archive) {
          {
            recommendation: {
              title: "test",
              reference: "1",
              is_archive: true
            }
          }
        }

        allowed_modify_archive_roles.each do |role|
          it "can be set by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't create at all
            next unless self.class.allowed_create_roles.include?(role)

            response = post :create, format: :json, params: params_with_archive
            expect(response).to be_created
            expect(JSON.parse(response.body).dig("data", "attributes", "is_archive")).to eq true
          end
        end

        forbidden_modify_archive_roles.each do |role|
          it "cannot be set by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't create at all
            next unless self.class.allowed_create_roles.include?(role)

            response = post :create, format: :json, params: params_with_archive
            expect(response).to be_created
            expect(JSON.parse(response.body).dig("data", "attributes", "is_archive")).to eq false
          end
        end
      end

      it "records what user created the recommendation", versioning: true do
        expect(PaperTrail).to be_enabled
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq admin.id
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        post :create, format: :json, params: {
          recommendation: {description: "desc only"}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:params) {
      {
        id: recommendation,
        recommendation: {
          title: "test update",
          description: "test update",
          target_date: "today update"
        }
      }
    }
    subject { put :update, format: :json, params: params }

    # Define roles at class level
    def self.allowed_update_roles
      @allowed_update_roles ||= Permissions.roles_with_permission("recommendation", "update")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_update_roles
      @forbidden_update_roles ||= all_roles - allowed_update_roles
    end

    def self.allowed_update_archived_roles
      @allowed_update_archived_roles ||= Permissions.roles_with_permission("recommendation", "update_archived")
    end

    def self.forbidden_update_archived_roles
      @forbidden_update_archived_roles ||= all_roles - allowed_update_archived_roles
    end

    context "when not signed in" do
      it "does not allow updating a recommendation" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to update a recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_update_roles.each do |role|
        it "allows #{role} to update a recommendation" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_ok
        end
      end

      forbidden_update_roles.each do |role|
        it "does not allow #{role} to update a recommendation" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      it "rejects an update where last_updated_at is older than updated_at in the database" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin

        recommendation_get = get :show, params: {id: recommendation}, format: :json
        json = JSON.parse(recommendation_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          response = put :update,
            format: :json,
            params: {
              id: recommendation,
              recommendation: {
                title: "test update",
                description: "test updateeee",
                target_date: "today update",
                updated_at: current_update_at
              }
            }
          expect(response).to be_ok
        end

        Timecop.travel(Time.new + 5.days) do
          response = put :update,
            format: :json,
            params: {
              id: recommendation,
              recommendation: {
                title: "test update",
                description: "test updatebbbb",
                target_date: "today update",
                updated_at: current_update_at
              }
            }
          expect(response).to_not be_ok
        end
      end

      it "records what user updated the recommendation", versioning: true do
        expect(PaperTrail).to be_enabled
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq admin.id
      end

      it "returns the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        guest = FactoryBot.create(:user)
        admin = FactoryBot.create(:user, :admin)
        recommendation.versions.first.update_column(:whodunnit, guest.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(admin.id)
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        put :update, format: :json, params: {
          id: recommendation,
          recommendation: {title: ""}
        }
        expect(response).to have_http_status(422)
      end

      context "when is_archive: true" do
        let(:archived_recommendation) { FactoryBot.create(:recommendation, :is_archive) }
        let(:archived_params) {
          {
            id: archived_recommendation,
            recommendation: {
              title: "test update",
              description: "test update",
              target_date: "today update"
            }
          }
        }

        allowed_update_archived_roles.each do |role|
          it "allows #{role} to update archived recommendation" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            response = put :update, format: :json, params: archived_params
            expect(response).to be_ok
          end
        end

        forbidden_update_archived_roles.each do |role|
          it "does not allow #{role} to update archived recommendation" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            response = put :update, format: :json, params: archived_params

            # If role can view archived, they see it but get forbidden
            # Otherwise they can't see it at all (not_found due to scope)
            allowed_view_archived = Permissions.roles_with_permission("recommendation", "view_archived")
            if allowed_view_archived.include?(role)
              expect(response).to be_forbidden
            else
              expect(response).to be_not_found
            end
          end
        end
      end
    end
  end

  describe "Delete destroy" do
    let(:recommendation) { FactoryBot.create(:recommendation) }
    subject { delete :destroy, format: :json, params: {id: recommendation} }

    # Define roles at class level
    def self.allowed_destroy_roles
      @allowed_destroy_roles ||= Permissions.roles_with_permission("recommendation", "destroy")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_destroy_roles
      @forbidden_destroy_roles ||= all_roles - allowed_destroy_roles
    end

    context "when not signed in" do
      it "does not allow deleting a recommendation" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete a recommendation" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      if allowed_destroy_roles.any?
        allowed_destroy_roles.each do |role|
          it "allows #{role} to delete a recommendation" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            expect(subject).to be_no_content
          end
        end
      else
        it "is disabled for all roles" do
          self.class.all_roles.each do |role|
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            expect(subject).to be_forbidden
          end
        end
      end

      forbidden_destroy_roles.each do |role|
        it "does not allow #{role} to delete a recommendation" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end

  describe "Permission system tests: recommendations" do
    include_examples "permission system",
      "recommendation",
      :create,
      :post,
      -> {
        {
          recommendation: {
            title: "test",
            description: "test",
            reference: "test-#{SecureRandom.hex(4)}" # Unique reference
          }
        }
      }

    include_examples "permission system",
      "recommendation",
      :update,
      :put,
      -> {
        recommendation = FactoryBot.create(:recommendation)
        {
          id: recommendation.id,
          recommendation: {
            title: "updated",
            description: "updated"
          }
        }
      }

    include_examples "permission system",
      "recommendation",
      :destroy,
      :delete,
      -> {
        recommendation = FactoryBot.create(:recommendation)
        {id: recommendation.id}
      }
  end
  describe "Scope permission system tests: recommendations" do
    include_examples "filtered scope permission system",
      "recommendation", :draft, "view_draft", true

    include_examples "filtered scope permission system",
      "recommendation", :is_archive, "view_archived", true

    include_examples "show with scope permission system",
      "recommendation", :draft, "view_draft", true

    include_examples "show with scope permission system",
      "recommendation", :is_archive, "view_archived", true
  end
end
