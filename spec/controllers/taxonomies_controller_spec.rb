require "rails_helper"
require "json"

RSpec.describe TaxonomiesController, type: :controller do
  describe "Get index" do
    subject { get :index, format: :json }
    let!(:taxonomy) { FactoryBot.create(:taxonomy) }

    context "when not signed in" do
      it { expect(subject).to be_ok }

      it "all published taxonomies" do
        json = JSON.parse(subject.body)
        expect(json["data"].length).to eq(1)
      end
    end
  end
end
