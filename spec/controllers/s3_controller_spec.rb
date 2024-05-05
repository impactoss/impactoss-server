require "rails_helper"
require "json"

RSpec.describe S3Controller, type: :controller do
  describe "GET sign" do
    let(:object_name) { "test_object" }
    subject { get :sign, format: :json, params: {objectName: object_name} }

    it { expect(subject).to be_ok }
    it { expect(subject.body).to eq(%({"error":"Not configured"})) }
  end
end
