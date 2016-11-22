require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "GET index" do
    subject { get :index }
    context "when not signed in" do
      it { expect(subject).not_to be_ok }
    end
    context "when signed in, but not admin" do
      before { sign_in }
      it { expect(subject).not_to be_ok }
    end
    context "when signed in as admin" do
      before { sign_in_admin }
      it { expect(subject).to be_ok }
    end
  end

  describe "GET edit" do
    let(:user) { FactoryGirl.create(:user) }
    subject { get :edit, params: { id: user.to_param } }
    context "when not signed in" do
      it { expect(subject).not_to be_ok }
    end
    context "when signed in, but not admin" do
      before { sign_in }
      it { expect(subject).not_to be_ok }
    end
    context "when signed in as admin" do
      before { sign_in_admin }
      it { expect(subject).to be_ok }
    end
  end

  describe "POST update" do
    let(:user) { FactoryGirl.create(:user) }
    let(:monkey_role) { FactoryGirl.create(:role, name: "monkey") }
    let(:valid_params) { { role_ids: [monkey_role.id] } }
    subject { post :update, params: { id: user.id, user: valid_params } }

    context "when not signed in" do
      it { expect(subject).to redirect_to(new_user_session_path) }
    end
    context "when signed in, but not admin" do
      before { sign_in }
      it { expect(subject).not_to be_ok }
    end
    context "when signed in as admin" do
      before { sign_in_admin }
      it { expect(subject).to redirect_to(users_path) }
      it "change user's roles" do
        subject
        expect(user.role?(monkey_role.name)).to eq(true)
      end
    end
  end
end
