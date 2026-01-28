# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe ProgressReportsController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }

  def serialized(subject_progress_report)
    ProgressReportSerializer.new(subject_progress_report).serializable_hash[:data].as_json
  end

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:progress_report) { FactoryBot.create(:progress_report, :published, title: "Published Progress Report") }
    let!(:archived_progress_report) { FactoryBot.create(:progress_report, :published, :is_archive, title: "Archived Progress Report") }
    let!(:draft_progress_report) { FactoryBot.create(:progress_report, :draft, title: "Draft Progress Report") }

    # Define roles at class level
    def self.allowed_view_archived_roles
      @allowed_view_archived_roles ||= Permissions.roles_with_permission("progress_report", "view_archived")
    end

    def self.allowed_view_draft_roles
      @allowed_view_draft_roles ||= Permissions.roles_with_permission("progress_report", "view_draft")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published progress_reports (no archived or draft)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(progress_report)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest will see only published progress_reports (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(progress_report)])
      end

      # Test each role's visibility based on permissions
      all_roles.each do |role|
        context role.to_s do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          it "sees appropriate progress_reports based on permissions" do
            sign_in user
            json = JSON.parse(subject.body)

            expected_reports = [progress_report] # Everyone sees published

            # Add archived if role has view_archived permission
            if self.class.allowed_view_archived_roles.include?(role)
              expected_reports << archived_progress_report
            end

            # Add draft if role has view_draft permission
            if self.class.allowed_view_draft_roles.include?(role)
              expected_reports << draft_progress_report
            end

            expect(json["data"]).to match_array(expected_reports.map { |r| serialized(r) })
          end
        end
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }
        let(:admin) { FactoryBot.create(:user, :admin) }

        it "will not show is_archived items" do
          sign_in admin
          json = JSON.parse(subject.body)
          expect(json["data"]).to match_array([serialized(progress_report), serialized(draft_progress_report)])
        end
      end
    end
  end

  describe "Get show" do
    let(:progress_report) { FactoryBot.create(:progress_report, :published, title: "Published Progress Report") }
    let(:archived_progress_report) { FactoryBot.create(:progress_report, :published, :is_archive, title: "Archived Progress Report") }
    let(:draft_progress_report) { FactoryBot.create(:progress_report, :draft, title: "Draft Progress Report") }

    def show(subject_progress_report)
      get :show, params: {
        id: subject_progress_report
      }, format: :json
    end

    context "when not signed in" do
      it { expect(show(progress_report)).to be_ok }

      it "shows the progress_report" do
        json = JSON.parse(show(progress_report).body)
        expect(json.dig("data", "id").to_i).to eq(progress_report.id)
      end

      it "will not show the archived progress_report" do
        show(archived_progress_report)
        expect(response).to be_not_found
      end

      it "will not show the draft progress_report" do
        show(draft_progress_report)
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    let(:due_date) { FactoryBot.create(:due_date) }
    let(:indicator) { FactoryBot.create(:indicator, :published) }
    let(:params) {
      {
        progress_report: {
          indicator_id: indicator.id,
          due_date_id: due_date.id,
          title: "test title",
          description: "test desc",
          document_url: "test_url",
          document_public: true
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles at class level
    def self.allowed_create_roles
      @allowed_create_roles ||= Permissions.roles_with_permission("progress_report", "create")
    end

    def self.allowed_create_own_roles
      @allowed_create_own_roles ||= Permissions.roles_with_permission("progress_report", "create_own_draft")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_create_roles
      @forbidden_create_roles ||= all_roles - allowed_create_roles
    end

    def self.allowed_modify_draft_roles
      @allowed_modify_draft_roles ||= Permissions.roles_with_permission("progress_report", "modify_draft")
    end

    def self.forbidden_modify_draft_roles
      @forbidden_modify_draft_roles ||= all_roles - allowed_modify_draft_roles
    end

    context "when not signed in" do
      it "does not allow creating a progress_report" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a progress_report" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_create_roles.each do |role|
        it "allows #{role} to create a progress_report" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_created
        end
      end

      forbidden_create_roles.each do |role|
        it "does not allow #{role} to create a progress_report" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "create_own_draft permission (contributors creating their own drafts)" do
        allowed_create_own_roles.each do |role|
          # Call the class method directly - we're already at class level here
          next if allowed_create_roles.include?(role)

          context "for #{role}" do
            let(:user) { FactoryBot.create(:user, role.to_sym) }
            let(:user_indicator) { FactoryBot.create(:indicator, :published, manager: user) }

            it "does not allow creating a non-draft progress_report for their own indicator" do
              sign_in user

              response = post :create, format: :json, params: {
                progress_report: {
                  indicator_id: user_indicator.id,
                  due_date_id: due_date.id,
                  title: "test title",
                  description: "test desc",
                  document_url: "test_url",
                  document_public: true,
                  draft: false
                }
              }
              expect(response).to be_forbidden
            end

            it "allows creating a draft progress_report for their own indicator" do
              sign_in user

              response = post :create, format: :json, params: {
                progress_report: {
                  indicator_id: user_indicator.id,
                  due_date_id: due_date.id,
                  title: "test title",
                  description: "test desc",
                  document_url: "test_url",
                  document_public: true,
                  draft: true
                }
              }
              expect(response).to be_created
            end

            it "does not allow creating a progress_report for an indicator they don't manage" do
              sign_in user
              expect(subject).to be_forbidden
            end
          end
        end
      end

      context "modify is_archive attribute" do
        let(:params_with_archive) {
          {
            progress_report: {
              indicator_id: indicator.id,
              due_date_id: due_date.id,
              title: "test title",
              description: "test desc",
              document_url: "test_url",
              document_public: true,
              is_archive: true
            }
          }
        }

        it "cannot be set on create (always defaults to false)" do
          # Test with any role that can create
          skip "No role can create indicators" if self.class.allowed_create_roles.empty?

          user = FactoryBot.create(:user, self.class.allowed_create_roles.first.to_sym)
          sign_in user

          response = post :create, format: :json, params: params_with_archive
          expect(response).to be_created
          # is_archive is always filtered on create, regardless of permissions
          expect(JSON.parse(response.body).dig("data", "attributes", "is_archive")).to eq false
        end
      end

      context "modify draft attribute" do
        let(:params_with_draft_false) {
          {
            progress_report: {
              indicator_id: indicator.id,
              due_date_id: due_date.id,
              title: "test title",
              description: "test desc",
              document_url: "test_url",
              document_public: true,
              draft: false
            }
          }
        }

        allowed_modify_draft_roles.each do |role|
          it "can be set to false (published) by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't create at all
            next unless self.class.allowed_create_roles.include?(role)

            response = post :create, format: :json, params: params_with_draft_false
            expect(response).to be_created
            expect(JSON.parse(response.body).dig("data", "attributes", "draft")).to eq false
          end
        end

        forbidden_modify_draft_roles.each do |role|
          it "cannot be set to false by #{role} (stays true/draft)" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't create at all
            next unless self.class.allowed_create_roles.include?(role)

            response = post :create, format: :json, params: params_with_draft_false
            expect(response).to be_created
            # draft filtered by permitted_attributes, defaults to true
            expect(JSON.parse(response.body).dig("data", "attributes", "draft")).to eq true
          end
        end
      end

      if allowed_create_roles.any?
        it "records what user created the progress_report", versioning: true do
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
            progress_report: {description: "desc only"}
          }
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  describe "PUT update" do
    let(:progress_report) { FactoryBot.create(:progress_report, :published) }
    let(:due_date) { FactoryBot.create(:due_date) }
    let(:indicator) { FactoryBot.create(:indicator, :published) }
    let(:params) {
      {
        id: progress_report,
        progress_report: {
          title: "test update",
          description: "test update"
        }
      }
    }
    subject { put :update, format: :json, params: params }

    # Define roles at class level
    def self.allowed_update_roles
      @allowed_update_roles ||= Permissions.roles_with_permission("progress_report", "update")
    end

    def self.allowed_update_own_roles
      @allowed_update_own_roles ||= Permissions.roles_with_permission("progress_report", "update_own_draft")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_update_roles
      @forbidden_update_roles ||= all_roles - allowed_update_roles
    end

    def self.allowed_update_archived_roles
      @allowed_update_archived_roles ||= Permissions.roles_with_permission("progress_report", "update_archived")
    end

    def self.forbidden_update_archived_roles
      @forbidden_update_archived_roles ||= all_roles - allowed_update_archived_roles
    end

    def self.allowed_modify_archive_roles
      @allowed_modify_archive_roles ||= Permissions.roles_with_permission("progress_report", "modify_is_archive")
    end

    def self.forbidden_modify_archive_roles
      @forbidden_modify_archive_roles ||= all_roles - allowed_modify_archive_roles
    end

    def self.allowed_modify_draft_roles
      @allowed_modify_draft_roles ||= Permissions.roles_with_permission("progress_report", "modify_draft")
    end

    def self.forbidden_modify_draft_roles
      @forbidden_modify_draft_roles ||= all_roles - allowed_modify_draft_roles
    end

    context "when not signed in" do
      it "does not allow updating a progress_report" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to update a progress_report" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_update_roles.each do |role|
        it "allows #{role} to update a progress_report" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_ok
        end
      end

      forbidden_update_roles.each do |role|
        it "does not allow #{role} to update a progress_report" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "update_own_draft permission (contributors updating their own drafts)" do
        allowed_update_own_roles.each do |role|
          # Skip roles that already have full update permission
          next if allowed_update_roles.include?(role)

          context "for #{role}" do
            let(:user) { FactoryBot.create(:user, role.to_sym) }
            let(:user_indicator) { FactoryBot.create(:indicator, :published, manager: user) }
            let(:other_indicator) { FactoryBot.create(:indicator, :published) }
            let(:user_draft_report) { FactoryBot.create(:progress_report, :draft, indicator: user_indicator) }
            let(:user_published_report) { FactoryBot.create(:progress_report, :published, indicator: user_indicator) }
            let(:other_draft_report) { FactoryBot.create(:progress_report, :draft, indicator: other_indicator) }

            it "allows updating their own draft progress_report" do
              sign_in user

              response = put :update, format: :json, params: {
                id: user_draft_report,
                progress_report: {title: "test update", description: "test update"}
              }
              expect(response).to be_ok
            end

            it "does not allow updating their own draft to published" do
              sign_in user

              response = put :update, format: :json, params: {
                id: user_draft_report,
                progress_report: {draft: false, title: "test update", description: "test update"}
              }
              expect(response).to be_forbidden
            end

            it "does not allow updating their own published progress_report" do
              sign_in user

              response = put :update, format: :json, params: {
                id: user_published_report,
                progress_report: {title: "test update", description: "test update"}
              }
              expect(response).to be_forbidden
            end

            it "does not allow updating a draft progress_report for an indicator they don't manage" do
              sign_in user

              response = put :update, format: :json, params: {
                id: other_draft_report,
                progress_report: {title: "test update", description: "test update"}
              }
              expect(response).to be_forbidden
            end
          end
        end
      end

      context "modify is_archive attribute" do
        let(:progress_report) { FactoryBot.create(:progress_report, :published) }
        let(:params_with_archive) {
          {
            id: progress_report,
            progress_report: {
              title: "test update",
              is_archive: true
            }
          }
        }

        allowed_modify_archive_roles.each do |role|
          it "can be set by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't update at all
            next unless self.class.allowed_update_roles.include?(role)

            response = put :update, format: :json, params: params_with_archive
            expect(response).to be_ok
            expect(JSON.parse(response.body).dig("data", "attributes", "is_archive")).to eq true
          end
        end

        forbidden_modify_archive_roles.each do |role|
          it "cannot be set by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't update at all
            next unless self.class.allowed_update_roles.include?(role)

            response = put :update, format: :json, params: params_with_archive
            expect(response).to be_ok
            # is_archive filtered by permitted_attributes, remains false
            expect(JSON.parse(response.body).dig("data", "attributes", "is_archive")).to eq false
          end
        end
      end

      context "modify draft attribute" do
        let(:progress_report) { FactoryBot.create(:progress_report, :draft) }
        let(:params_with_draft_false) {
          {
            id: progress_report,
            progress_report: {
              title: "test update",
              draft: false
            }
          }
        }

        allowed_modify_draft_roles.each do |role|
          it "can be changed by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't update at all
            next unless self.class.allowed_update_roles.include?(role)

            response = put :update, format: :json, params: params_with_draft_false
            expect(response).to be_ok
            expect(JSON.parse(response.body).dig("data", "attributes", "draft")).to eq false
          end
        end

        forbidden_modify_draft_roles.each do |role|
          it "cannot be changed by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't update at all
            next unless self.class.allowed_update_roles.include?(role)

            response = put :update, format: :json, params: params_with_draft_false
            expect(response).to be_ok
            # draft filtered by permitted_attributes, remains true
            expect(JSON.parse(response.body).dig("data", "attributes", "draft")).to eq true
          end
        end
      end

      context "when is_archive: true" do
        let(:archived_report) { FactoryBot.create(:progress_report, :published, :is_archive) }
        let(:archived_params) {
          {
            id: archived_report,
            progress_report: {
              title: "test update",
              description: "test update"
            }
          }
        }

        allowed_update_archived_roles.each do |role|
          it "allows #{role} to update archived progress_report" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            response = put :update, format: :json, params: archived_params
            expect(response).to be_ok
          end
        end

        forbidden_update_archived_roles.each do |role|
          it "does not allow #{role} to update archived progress_report" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            response = put :update, format: :json, params: archived_params

            # If role can view archived, they see it but get forbidden
            # Otherwise they can't see it at all (not_found due to scope)
            allowed_view_archived = Permissions.roles_with_permission("progress_report", "view_archived")
            if allowed_view_archived.include?(role)
              expect(response).to be_forbidden
            else
              expect(response).to be_not_found
            end
          end
        end

        # Test that update_own_draft doesn't bypass the archived check
        (allowed_update_own_roles - allowed_update_archived_roles).each do |role|
          it "does not allow #{role} to update their own archived draft (archived check takes precedence)" do
            user = FactoryBot.create(:user, role.to_sym)
            user_indicator = FactoryBot.create(:indicator, :published, manager: user)
            archived_draft = FactoryBot.create(:progress_report, :draft, :is_archive, indicator: user_indicator)

            sign_in user
            response = put :update, format: :json, params: {
              id: archived_draft,
              progress_report: {title: "test update", description: "test update"}
            }

            # Check view_archived permission for expected response
            allowed_view_archived = Permissions.roles_with_permission("progress_report", "view_archived")
            if allowed_view_archived.include?(role)
              expect(response).to be_forbidden  # Sees it but blocked by archived check
            else
              expect(response).to be_not_found  # Can't see archived items
            end
          end
        end
      end

      it "does not allow the indicator_id to be updated" do
        admin = FactoryBot.create(:user, :admin)
        new_indicator = FactoryBot.create(:indicator, :published)
        sign_in admin

        put :update, format: :json, params: {
          id: progress_report,
          progress_report: {
            indicator_id: new_indicator.id,
            title: "test update",
            description: "test update"
          }
        }

        expect(response).to_not be_ok
        expect(JSON.parse(response.body).dig("error", "indicator_id")).to include("cannot be changed after the report has been created")
      end

      it "rejects an update where last_updated_at is older than updated_at in the database" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin

        progress_report_get = get :show, params: {id: progress_report}, format: :json
        json = JSON.parse(progress_report_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          response = put :update,
            format: :json,
            params: {
              id: progress_report,
              progress_report: {
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
              id: progress_report,
              progress_report: {
                title: "test update",
                description: "test updatebbbb",
                target_date: "today update",
                updated_at: current_update_at
              }
            }
          expect(response).to_not be_ok
        end
      end

      it "records what user updated the progress_report", versioning: true do
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
        progress_report.versions.first.update_column(:whodunnit, guest.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(admin.id)
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        put :update, format: :json, params: {
          id: progress_report,
          progress_report: {title: ""}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:progress_report) { FactoryBot.create(:progress_report, :published) }
    subject { delete :destroy, format: :json, params: {id: progress_report} }

    context "when not signed in" do
      it "does not allow deleting a progress_report" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete a progress_report" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      # Progress reports cannot be deleted - blocked in policy
      it "is blocked for all roles (progress reports cannot be deleted)" do
        Permissions::ROLE_HIERARCHY.keys.each do |role|
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end
end
