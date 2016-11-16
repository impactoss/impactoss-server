require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "GET index" do
    subject { get :index }
    context "not signed in" do
      it { expect(subject).not_to be_ok }
    end
    context "is signed in, but not admin" do
      before { sign_in }
      it { expect(subject).not_to be_ok }
    end
    context "is signed in as admin" do
      before { sign_in_admin }
      it { expect(subject).to be_ok }
    end
  end
end
