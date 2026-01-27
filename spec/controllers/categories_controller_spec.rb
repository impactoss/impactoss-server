require "rails_helper"
require "json"

RSpec.describe CategoriesController, type: :controller do
  def serialized(subject_category)
    CategorySerializer.new(subject_category).serializable_hash[:data].as_json
  end

  describe "Get index" do
    subject { get :index, format: :json }

    let(:category) { FactoryBot.create(:category) } # published
    let(:archived_category) { FactoryBot.create(:category, is_archive: true) }
    let(:draft_category) { FactoryBot.create(:category, draft: true) }

    # Define roles at class level
    def self.allowed_view_archived_roles
      @allowed_view_archived_roles ||= Permissions.roles_with_permission("category", "view_archived")
    end

    def self.allowed_view_draft_roles
      @allowed_view_draft_roles ||= Permissions.roles_with_permission("category", "view_draft")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    before do
      # Create all categories before each test
      category
      archived_category
      draft_category
    end

    context "when not signed in" do
      it "is expected to be ok" do
        expect(subject).to be_ok
      end

      it "will see only published categories (no archived or drafts)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(category)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "guest will see only published categories (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(category)])
      end

      # Test each role's visibility based on permissions
      all_roles.each do |role|
        context "#{role}" do
          let(:user) { FactoryBot.create(:user, role.to_sym) }

          it "sees appropriate categories based on permissions" do
            sign_in user
            json = JSON.parse(subject.body)

            expected_categories = [category] # Everyone sees published

            # Add archived if role has view_archived permission - use self.class to access class method
            if self.class.allowed_view_archived_roles.include?(role)
              expected_categories << archived_category
            end

            # Add draft if role has view_draft permission - use self.class to access class method
            if self.class.allowed_view_draft_roles.include?(role)
              expected_categories << draft_category
            end

            expect(json["data"]).to match_array(expected_categories.map { |cat| serialized(cat) })
          end
        end
      end
    end
  end

  describe "Get show" do
    let!(:category) { FactoryBot.create(:category, reference: "Published Category") }
    let!(:archived_category) { FactoryBot.create(:category, is_archive: true, reference: "Archived Category") }
    let!(:draft_category) { FactoryBot.create(:category, draft: true, reference: "Draft Category") }

    def show(subject_category)
      get :show, params: {
        id: subject_category
      }, format: :json
    end

    context "when not signed in" do
      it { expect(show(category)).to be_ok }

      it "shows the published category" do
        show(category)
        json = JSON.parse(response.body)
        expect(json["data"]).to eq(serialized(category))
      end

      it "will not show archived category" do
        show(archived_category)
        expect(response).to be_not_found
      end

      it "will not show draft category" do
        show(draft_category)
        expect(response).to be_not_found
      end
    end
  end

  describe "Post create" do
    let(:taxonomy) { FactoryBot.create(:taxonomy) }
    let(:params) {
      {
        category: {
          title: "test",
          short_title: "bla",
          description: "test",
          target_date: "today",
          taxonomy_id: taxonomy.id
        }
      }
    }
    subject { post :create, format: :json, params: params }

    # Define roles once at the top of the describe block
    def self.allowed_create_roles
      @allowed_create_roles ||= Permissions.roles_with_permission("category", "create")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_create_roles
      @forbidden_create_roles ||= all_roles - allowed_create_roles
    end

    def self.allowed_modify_archive_roles
      @allowed_modify_archive_roles ||= Permissions.roles_with_permission("category", "modify_is_archive")
    end

    def self.forbidden_modify_archive_roles
      @forbidden_modify_archive_roles ||= all_roles - allowed_modify_archive_roles
    end

    context "when not signed in" do
      it "does not allow creating a category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to create a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_create_roles.each do |role|
        it "allows #{role} to create a category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_created
        end
      end

      forbidden_create_roles.each do |role|
        it "does not allow #{role} to create a category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "is_archive attribute" do
        let(:params_with_archive) {
          {
            category: {
              title: "test",
              short_title: "bla",
              description: "test",
              target_date: "today",
              taxonomy_id: taxonomy.id,
              is_archive: true
            }
          }
        }

        allowed_modify_archive_roles.each do |role|
          it "can be set by #{role}" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Access class method from instance context
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

            # Access class method from instance context
            next unless self.class.allowed_create_roles.include?(role)

            response = post :create, format: :json, params: params_with_archive
            expect(response).to be_created
            expect(JSON.parse(response.body).dig("data", "attributes", "is_archive")).to eq false
          end
        end
      end

      it "records what user created the category", versioning: true do
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
          category: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Put update" do
    let(:category) { FactoryBot.create(:category) }
    let(:params) {
      {
        id: category,
        category: {
          title: "test update",
          description: "test update",
          target_date: "today update"
        }
      }
    }
    subject { put :update, format: :json, params: params }

    # Define roles at class level
    def self.allowed_update_roles
      @allowed_update_roles ||= Permissions.roles_with_permission("category", "update")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_update_roles
      @forbidden_update_roles ||= all_roles - allowed_update_roles
    end

    def self.allowed_modify_manager_id_roles
      @allowed_modify_manager_id_roles ||= Permissions.roles_with_permission("category", "modify_manager_id")
    end

    def self.forbidden_modify_manager_id_roles
      @forbidden_modify_manager_id_roles ||= all_roles - allowed_modify_manager_id_roles
    end

    context "when not signed in" do
      it "does not allow updating a category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to update a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      allowed_update_roles.each do |role|
        it "allows #{role} to update a category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_ok
        end
      end

      forbidden_update_roles.each do |role|
        it "does not allow #{role} to update a category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end

      context "manager_id attribute" do
        # Get the minimum role that can be assigned as manager
        def self.allowed_assign_roles
          @allowed_assign_roles ||= Permissions.roles_with_permission('category', 'assign_as_responsible')
        end

        # Create a user with the minimum assignable role
        let(:assignable_user) {
          min_role = self.class.allowed_assign_roles.first
          FactoryBot.create(:user, min_role.to_sym)
        }

        allowed_modify_manager_id_roles.each do |role|
          it "allows #{role} to update manager_id" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't update at all
            next unless self.class.allowed_update_roles.include?(role)

            expect {
              put :update,
                format: :json,
                params: {
                  id: category,
                  category: { manager_id: assignable_user.id }
                }
            }.to change { category.reload.manager_id }.to(assignable_user.id)

            expect(response).to be_ok
          end
        end

        forbidden_modify_manager_id_roles.each do |role|
          it "does not allow #{role} to update manager_id" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user

            # Skip if this role can't update at all
            next unless self.class.allowed_update_roles.include?(role)

            expect {
              put :update,
                format: :json,
                params: {
                  id: category,
                  category: { manager_id: assignable_user.id }
                }
            }.not_to change { category.reload.manager_id }

            # Rails silently filters unpermitted attributes - returns OK but ignores the attribute
            expect(response).to be_ok
          end
        end
      end

      it "rejects an update where last_updated_at is older than updated_at in the database" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin

        category_get = get :show, params: {id: category}, format: :json
        json = JSON.parse(category_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          response = put :update,
            format: :json,
            params: {
              id: category,
              category: {
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
              id: category,
              category: {
                title: "test update",
                description: "test updatebbbb",
                target_date: "today update",
                updated_at: current_update_at
              }
            }
          expect(response).to_not be_ok
        end
      end

      it "records what user updated the category", versioning: true do
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
        category.versions.first.update_column(:whodunnit, guest.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(admin.id)
      end

      it "returns an error if params are incorrect" do
        admin = FactoryBot.create(:user, :admin)
        sign_in admin
        put :update, format: :json, params: {
          id: category,
          category: {taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:category) { FactoryBot.create(:category) }
    subject {
      delete :destroy, format: :json, params: {id: category}
    }

    # Define roles at class level
    def self.allowed_destroy_roles
      @allowed_destroy_roles ||= Permissions.roles_with_permission("category", "destroy")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_destroy_roles
      @forbidden_destroy_roles ||= all_roles - allowed_destroy_roles
    end

    context "when not signed in" do
      it "does not allow deleting a category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }

      it "does not allow a guest (no roles) to delete a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      if allowed_destroy_roles.any?
        allowed_destroy_roles.each do |role|
          it "allows #{role} to delete a category" do
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            expect(subject).to be_no_content
          end
        end
      else
        it "is disabled for all roles" do
          self.class.all_roles.each do |role|  # Use self.class here
            user = FactoryBot.create(:user, role.to_sym)
            sign_in user
            expect(subject).to be_forbidden
          end
        end
      end

      forbidden_destroy_roles.each do |role|
        it "does not allow #{role} to delete a category" do
          user = FactoryBot.create(:user, role.to_sym)
          sign_in user
          expect(subject).to be_forbidden
        end
      end
    end
  end

  describe "Permission system tests: categories" do
    include_examples "permission system",
      "category",
      :create,
      :post,
      -> {
        {
          category: {
            title: "test",
            description: "test",
            reference: "test-#{SecureRandom.hex(4)}", # Unique reference
            date: Date.today
          }
        }
      }

    include_examples "permission system",
      "category",
      :update,
      :put,
      -> {
        category = FactoryBot.create(:category)
        {
          id: category.id,
          category: {
            title: "updated",
            description: "updated"
          }
        }
      }

    include_examples "permission system",
      "category",
      :destroy,
      :delete,
      -> {
        category = FactoryBot.create(:category)
        {id: category.id}
      }
  end
  describe "Scope permission system tests: categories" do
    include_examples "filtered scope permission system",
      "category", :draft, "view_draft", true

    include_examples "filtered scope permission system",
      "category", :is_archive, "view_archived", true

    include_examples "show with scope permission system",
      "category", :draft, "view_draft", true

    include_examples "show with scope permission system",
      "category", :is_archive, "view_archived", true
  end
end
