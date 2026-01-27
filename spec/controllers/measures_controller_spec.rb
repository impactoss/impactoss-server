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

    # Define roles at class level
    def self.allowed_view_archived_roles
      @allowed_view_archived_roles ||= Permissions.roles_with_permission("measure", "view_archived")
    end

    def self.allowed_view_draft_roles
      @allowed_view_draft_roles ||= Permissions.roles_with_permission("measure", "view_draft")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published measures (no archived or drafts)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(measure)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest will see only published measures (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(measure)])
      end

      # Test each role's visibility based on permissions
      all_roles.each do |role|
        context "#{role}" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          it "sees appropriate measures based on permissions" do
            sign_in user
            json = JSON.parse(subject.body)

            expected_measures = [measure] # Everyone sees published

            # Add archived if role has view_archived permission
            if self.class.allowed_view_archived_roles.include?(role)
              expected_measures << archived_measure
            end

            # Add draft if role has view_draft permission
            if self.class.allowed_view_draft_roles.include?(role)
              expected_measures << draft_measure
            end

            expect(json["data"]).to match_array(expected_measures.map { |m| serialized(m) })
          end
        end
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }

        it "will not show is_archived items" do
          sign_in admin
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
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:category) { FactoryBot.create(:category) }
    let(:params) {
      {
        measure: {
          description: "test",
          reference: "test reference",
          target_date: Date.today,
          title: "test"
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles once at the top of the describe block
    def self.allowed_create_roles
      @allowed_create_roles ||= Permissions.roles_with_permission("measure", "create")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_create_roles
      @forbidden_create_roles ||= all_roles - allowed_create_roles
    end

    def self.allowed_modify_archive_roles
      @allowed_modify_archive_roles ||= Permissions.roles_with_permission("measure", "modify_is_archive")
    end

    def self.forbidden_modify_archive_roles
      @forbidden_modify_archive_roles ||= all_roles - allowed_modify_archive_roles
    end

    context "when not signed in" do
      it "does not allow creating a measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_create_roles.each do |role|
        it "allows #{role} to create a measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_created
        end
      end

      forbidden_create_roles.each do |role|
        it "does not allow #{role} to create a measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "is_archive attribute" do
        let(:params_with_archive) {
          {
            measure: {
              description: "test",
              is_archive: true,
              reference: "test reference",
              target_date: Date.today,
              title: "test"
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
      if allowed_create_roles.any?
        it "records what user created the measure", versioning: true do
          expect(PaperTrail).to be_enabled
          admin = FactoryBot.create(:user, :admin)
          sign_in admin
          json = JSON.parse(subject.body)
          expect(json.dig("data", "attributes", "created_by_id").to_i).to eq admin.id
        end
      end
      if allowed_create_roles.any?
        it "returns an error if params are incorrect" do
          admin = FactoryBot.create(:user, :admin)
          sign_in admin
          post :create, format: :json, params: {
            measure: {description: "desc only"}
          }
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  describe "PUT update" do
    let(:measure) { FactoryBot.create(:measure) }
    let(:params) {
      {
        id: measure,
        measure: {
          title: "test update",
          description: "test update",
          reference: "test reference update",
          target_date: Date.today
        }
      }
    }
    subject { put :update, format: :json, params: params }

    # Define roles at class level
    def self.allowed_update_roles
      @allowed_update_roles ||= Permissions.roles_with_permission("measure", "update")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_update_roles
      @forbidden_update_roles ||= all_roles - allowed_update_roles
    end

    def self.allowed_update_archived_roles
      @allowed_update_archived_roles ||= Permissions.roles_with_permission("measure", "update_archived")
    end

    def self.forbidden_update_archived_roles
      @forbidden_update_archived_roles ||= all_roles - allowed_update_archived_roles
    end

    context "when not signed in" do
      it "does not allow updating a measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to update a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_update_roles.each do |role|
        it "allows #{role} to update a measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_ok
        end
      end

      forbidden_update_roles.each do |role|
        it "does not allow #{role} to update a measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      it "rejects an update where last_updated_at is older than updated_at in the database" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin

        measure_get = get :show, params: {id: measure}, format: :json
        json = JSON.parse(measure_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          response = put :update,
            format: :json,
            params: {
              id: measure,
              measure: {
                title: "test update",
                description: "test updateeee",
                target_date: Date.today,
                updated_at: current_update_at
              }
            }
          expect(response).to be_ok
        end

        Timecop.travel(Time.new + 5.days) do
          response = put :update,
            format: :json,
            params: {
              id: measure,
              measure: {
                title: "test update",
                description: "test updatebbbb",
                target_date: Date.today,
                updated_at: current_update_at
              }
            }
          expect(response).to_not be_ok
        end
      end

      it "records what user updated the measure", versioning: true do
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
        measure.versions.first.update_column(:whodunnit, guest.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(admin.id)
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        put :update, format: :json, params: {
          id: measure,
          measure: {title: ""}
        }
        expect(response).to have_http_status(422)
      end

      context "when is_archive: true" do
        let(:archived_measure) { FactoryBot.create(:measure, :is_archive) }
        let(:archived_params) {
          {
            id: archived_measure,
            measure: {
              title: "test update",
              description: "test update",
              target_date: Date.today
            }
          }
        }

        allowed_update_archived_roles.each do |role|
          it "allows #{role} to update archived measure" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            response = put :update, format: :json, params: archived_params
            expect(response).to be_ok
          end
        end

        forbidden_update_archived_roles.each do |role|
          it "does not allow #{role} to update archived measure" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            response = put :update, format: :json, params: archived_params

            # If role can view archived, they see it but get forbidden
            # Otherwise they can't see it at all (not_found due to scope)
            allowed_view_archived = Permissions.roles_with_permission("measure", "view_archived")
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
    let(:measure) { FactoryBot.create(:measure) }
    subject { delete :destroy, format: :json, params: {id: measure} }

    # Define roles at class level
    def self.allowed_destroy_roles
      @allowed_destroy_roles ||= Permissions.roles_with_permission("measure", "destroy")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_destroy_roles
      @forbidden_destroy_roles ||= all_roles - allowed_destroy_roles
    end

    context "when not signed in" do
      it "does not allow deleting a measure" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete a measure" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      if allowed_destroy_roles.any?
        allowed_destroy_roles.each do |role|
          it "allows #{role} to delete a measure" do
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
        it "does not allow #{role} to delete a measure" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end

  describe "Permission system tests: measures" do
    include_examples "permission system",
      "measure",
      :create,
      :post,
      -> {
        {
          measure: {
            title: "test",
            description: "test",
            reference: "test-#{SecureRandom.hex(4)}", # Unique reference
            target_date: Date.today
          }
        }
      }

    include_examples "permission system",
      "measure",
      :update,
      :put,
      -> {
        measure = FactoryBot.create(:measure)
        {
          id: measure.id,
          measure: {
            title: "updated",
            description: "updated"
          }
        }
      }

    include_examples "permission system",
      "measure",
      :destroy,
      :delete,
      -> {
        measure = FactoryBot.create(:measure)
        {id: measure.id}
      }
  end
  describe "Scope permission system tests: measures" do
    include_examples "filtered scope permission system",
      "measure", :draft, "view_draft", true

    include_examples "filtered scope permission system",
      "measure", :is_archive, "view_archived", true

    include_examples "show with scope permission system",
      "measure", :draft, "view_draft", true

    include_examples "show with scope permission system",
      "measure", :is_archive, "view_archived", true
  end
end
