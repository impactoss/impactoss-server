require "rails_helper"
require "json"

RSpec.describe CategoriesController, type: :controller do
  def serialized(subject_category)
    serialized_record(subject_category, CategorySerializer)
  end

  describe "Get index" do
    subject { get :index, format: :json }
    let!(:category) { FactoryBot.create(:category, reference: "Published Category") }
    let!(:archived_category) { FactoryBot.create(:category, is_archive: true, reference: "Archived Category") }
    let!(:draft_category) { FactoryBot.create(:category, draft: true, reference: "Draft Category") }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "will see only published categories (no archived or drafts)" do
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(category)])
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "guest will see only published categories (no archived or draft)" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([serialized(category)])
      end

      it "contributor will see all categories" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(category),
          serialized(archived_category),
          serialized(draft_category)
        ])
      end

      it "manager will see all categories" do
        sign_in manager
        json = JSON.parse(subject.body)
        expect(json["data"]).to match_array([
          serialized(category),
          serialized(archived_category),
          serialized(draft_category)
        ])
      end

      context "when include_archive=false" do
        subject { get :index, format: :json, params: {include_archive: false} }

        it "will not show is_archived items" do
          sign_in manager
          json = JSON.parse(subject.body)
          expect(json["data"]).to match_array([
            serialized(category),
            serialized(draft_category)
          ])
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
    context "when not signed in" do
      it "not allow creating a category" do
        post :create, format: :json, params: {
          category: {title: "test", description: "test", target_date: "today"}
        }
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:admin) { FactoryBot.create(:user, :admin) }
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

      subject { post :create, format: :json, params: }

      it "will not allow a guest to create a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to create a category" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to create a category" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      context "is_archive" do
        let(:params) {
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

        it "can be set by admin" do
          sign_in admin
          expect(subject).to be_created
          expect(JSON.parse(subject.body).dig("data", "attributes", "is_archive")).to eq true
        end
      end

      it "will record what user created the category", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "created_by_id").to_i).to eq admin.id
      end

      it "will return an error if params are incorrect" do
        sign_in admin
        post :create, format: :json, params: {
          category: {description: "desc only", taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT update" do
    let(:category) { FactoryBot.create(:category) }
    subject do
      put :update,
        format: :json,
        params: {
          id: category,
          category: {title: "test update", description: "test update", target_date: "today update"}
        }
    end

    context "when not signed in" do
      it "not allow updating a category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:admin) { FactoryBot.create(:user, :admin) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to update a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to update a category" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to update manager_id" do
        sign_in manager
        expect {
          put :update,
            format: :json,
            params: {
              id: category,
              category: {manager_id: manager.id}
            }
        }.not_to change { category.reload.manager_id }

        expect(response).to be_forbidden
      end

      it "will allow an admin to update manager_id" do
        sign_in admin
        expect {
          put :update,
            format: :json,
            params: {
              id: category,
              category: {manager_id: manager.id}
            }
        }.to change { category.reload.manager_id }.to(manager.id)

        expect(response).to be_ok
      end

      it "will not allow a contributor to update a category" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will reject an update where the last_updated_at is older than updated_at in the database" do
        sign_in admin
        category_get = get :show, params: {
          id: category
        }, format: :json
        json = JSON.parse(category_get.body)
        current_update_at = json.dig("data", "attributes", "updated_at")

        Timecop.travel(Time.new + 15.days) do
          subject = put :update,
            format: :json,
            params: {
              id: category,
              category: {title: "test update", description: "test updateeee", target_date: "today update", updated_at: current_update_at}
            }
          expect(subject).to be_ok
        end
        Timecop.travel(Time.new + 5.days) do
          subject = put :update,
            format: :json,
            params: {
              id: category,
              category: {title: "test update", description: "test updatebbbb", target_date: "today update", updated_at: current_update_at}
            }
          expect(subject).to_not be_ok
        end
      end

      it "will record what user updated the category", versioning: true do
        expect(PaperTrail).to be_enabled
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq admin.id
      end

      it "will return the latest updated_by", versioning: true do
        expect(PaperTrail).to be_enabled
        category.versions.first.update_column(:whodunnit, guest.id)
        sign_in admin
        json = JSON.parse(subject.body)
        expect(json.dig("data", "attributes", "updated_by_id").to_i).to eq(admin.id)
      end

      it "will return an error if params are incorrect" do
        sign_in admin
        put :update, format: :json, params: {
          id: category, category: {taxonomy_id: 999}
        }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:category) { FactoryBot.create(:category) }
    subject {
      delete :destroy, format: :json, params: {
        id: category
      }
    }

    context "when not signed in" do
      it "not allow deleting a category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }

      it "will not allow a guest to delete a category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to delete a category" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will not allow a manager to delete a category" do
        sign_in manager
        expect(subject).to be_forbidden
      end

      it "will not allow an admin to delete a category" do
        sign_in manager
        expect(subject).to be_forbidden
      end
    end
  end
end
