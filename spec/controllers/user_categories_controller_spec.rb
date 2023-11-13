require "rails_helper"
require "json"

RSpec.describe UserCategoriesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }
    end
  end

  describe "Get show" do
    let(:user_category) { FactoryBot.create(:user_category) }
    subject { get :show, params: {id: user_category}, format: :json }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "shows the user_category" do
        json = JSON.parse(subject.body)
        expect(json["data"]["id"].to_i).to eq(user_category.id)
      end
    end
  end

  describe "Post create" do
    context "when not signed in" do
      it "not allow creating a user_category" do
        post :create, format: :json, params: {user_category: {user_id: 1, category_id: 1}}
        expect(response).to be_unauthorized
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:manager) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:user) { FactoryBot.create(:user) }
      let(:category) { FactoryBot.create(:category) }

      subject do
        post :create,
          format: :json,
          params: {
            user_category: {
              user_id: user.id,
              category_id: category.id
            }
          }
      end

      it "will not allow a guest to create a user_category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to create a user_category" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to create a user_category" do
        sign_in manager
        expect(subject).to be_created
      end

      it "will return an error if params are incorrect" do
        sign_in manager
        post :create, format: :json, params: {user_category: {description: "desc only", taxonomy_id: 999}}
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "Delete destroy" do
    let(:user_category) { FactoryBot.create(:user_category) }
    subject { delete :destroy, format: :json, params: {id: user_category} }

    context "when not signed in" do
      it "not allow deleting a user_category" do
        expect(subject).to be_unauthorized
      end
    end

    context "when user signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }

      it "will not allow a guest to delete a user_category" do
        sign_in guest
        expect(subject).to be_forbidden
      end

      it "will not allow a contributor to delete a user_category" do
        sign_in contributor
        expect(subject).to be_forbidden
      end

      it "will allow a manager to delete a user_category" do
        sign_in user
        expect(subject).to be_no_content
      end
    end
  end
end
