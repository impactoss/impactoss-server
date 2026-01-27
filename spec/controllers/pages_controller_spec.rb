require "rails_helper"
require "json"

RSpec.describe PagesController, type: :controller do
  def serialized(subject_page)
    PageSerializer.new(subject_page).serializable_hash[:data].as_json
  end

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:page) { FactoryBot.create(:page, title: "Published Page") }
    let!(:archived_page) { FactoryBot.create(:page, is_archive: true, title: "Archived Page") }
    let!(:draft_page) { FactoryBot.create(:page, draft: true, title: "Draft Page") }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published pages (no archived or draft)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(page)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "guest will see only published pages (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(page)])
      end

      it "contributor will see all pages" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(page),
          serialized(archived_page),
          serialized(draft_page)
        ])
      end

      it "manager will see all pages" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(page),
          serialized(archived_page),
          serialized(draft_page)
        ])
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }

        it "will not show is_archived items" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"]).to match_array([serialized(page), serialized(draft_page)])
        end
      end
    end
  end

  describe "Get show" do
    let(:page) { FactoryBot.create(:page, title: "Published Page") }
    let(:archived_page) { FactoryBot.create(:page, is_archive: true, title: "Archived Page") }
    let(:draft_page) { FactoryBot.create(:page, draft: true, title: "Draft Page") }

    def show(subject_page)
      get :show, params: {id: subject_page}, format: :json
    end

    context "when not signed in" do
      it { expect(show(page)).to be_ok }

      it "shows the published page" do
        json = JSON.parse(show(page).body)
        expect(json.dig("data", "id").to_i).to eq(page.id)
      end

      it "will not show the archived page" do
        show(archived_page)
        expect(response).to be_not_found
      end

      it "will not show the draft page" do
        show(draft_page)
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    let(:taxonomy) { FactoryBot.create(:taxonomy) }
    let(:params) {
      {
        page: {
          title: "test",
          content: "bla",
          menu_title: "test"
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles once at the top of the describe block
    def self.allowed_create_roles
      @allowed_create_roles ||= Permissions.roles_with_permission('page', 'create')
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_create_roles
      @forbidden_create_roles ||= all_roles - allowed_create_roles
    end

    def self.allowed_modify_archive_roles
      @allowed_modify_archive_roles ||= Permissions.roles_with_permission('page', 'modify_is_archive')
    end

    def self.forbidden_modify_archive_roles
      @forbidden_modify_archive_roles ||= all_roles - allowed_modify_archive_roles
    end

    context "when not signed in" do
      it "does not allow creating a page" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a page" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_create_roles.each do |role|
        it "allows #{role} to create a page" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_created
        end
      end

      forbidden_create_roles.each do |role|
        it "does not allow #{role} to create a page" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "is_archive attribute" do
        let(:params_with_archive) {
          {
            page: {
              title: "test",
              content: "bla",
              menu_title: "test",
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

      it "records what user created the page", versioning: true do
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
          page: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:page) { FactoryBot.create(:page) }
    let(:params) {
      {
        id: page,
        page: {
          title: "test update",
          description: "test update",
          target_date: "today update"
        }
      }
    }
    subject { put :update, format: :json, params: params }

    # Define roles at class level
    def self.allowed_update_roles
      @allowed_update_roles ||= Permissions.roles_with_permission('page', 'update')
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_update_roles
      @forbidden_update_roles ||= all_roles - allowed_update_roles
    end

    context "when not signed in" do
      it "does not allow updating a page" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to update a page" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_update_roles.each do |role|
        it "allows #{role} to update a page" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_ok
        end
      end

      forbidden_update_roles.each do |role|
        it "does not allow #{role} to update a page" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      it "rejects an update where last_updated_at is older than updated_at in the database" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin

        page_get = get :show, params: { id: page }, format: :json
        json = JSON.parse(page_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          response = put :update,
            format: :json,
            params: {
              id: page,
              page: {
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
              id: page,
              page: {
                title: "test update",
                description: "test updatebbbb",
                target_date: "today update",
                updated_at: current_update_at
              }
            }
          expect(response).to_not be_ok
        end
      end

      it "records what user updated the page", versioning: true do
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
        page.versions.first.update_column(:whodunnit, guest.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(admin.id)
      end
    end
  end

  describe "Delete destroy" do
    let(:page) { FactoryBot.create(:page) }
    subject { delete :destroy, format: :json, params: {id: page} }

    context "when not signed in" do
      it "not allow deleting a page" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "will not allow a guest to delete a page" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to delete a page" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete a page" do
        sign_in admin
        expect(subject).to be_forbidden
      end
    end
  end

  describe "Permission system tests: pages" do
    include_examples "permission system",
      'page',
      :create,
      :post,
      -> { {
        page: {
          title: "test",
          content: "test"
        }
      } }

    include_examples "permission system",
     'page',
     :update,
     :put,
     -> {
       page = FactoryBot.create(:page)
       {
         id: page.id,
         page: {
           title: "updated",
           content: "updated"
         }
       }
     }

   include_examples "permission system",
     'page',
     :destroy,
     :delete,
     -> {
       page = FactoryBot.create(:page)
       { id: page.id }
     }
  end
  describe "Scope permission system tests: pages" do
    include_examples "filtered scope permission system",
      'page', :draft, 'view_draft', true

    include_examples "filtered scope permission system",
      'page', :is_archive, 'view_archived', true

    include_examples "show with scope permission system",
      'page', :draft, 'view_draft', true

    include_examples "show with scope permission system",
      'page', :is_archive, 'view_archived', true
  end
end
