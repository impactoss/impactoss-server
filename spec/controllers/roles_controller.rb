# frozen_string_literal: true

require "rails_helper"
require "json"

RSpec.describe RolesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }
    let!(:role) { FactoryBot.create(:role) }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "roles are shown" do
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
      end
    end

    context "when signed in" do
      let(:guest) { FactoryBot.create(:user) }
      let(:user) { FactoryBot.create(:user, :manager) }
      let(:contributor) { FactoryBot.create(:user, :contributor) }
      let(:admin) { FactoryBot.create(:user, :admin) }

      it "guest will see roles" do
        sign_in guest
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
      end

      it "contributor will see roles" do
        sign_in contributor
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "manager will see roles" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end

      it "admin will see roles" do
        sign_in user
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(2)
      end
    end
  end
end
