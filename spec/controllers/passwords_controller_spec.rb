# spec/controllers/passwords_controller_spec.rb
require "rails_helper"

RSpec.describe PasswordsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#redirect_options" do
    let(:controller_instance) { described_class.new }

    before do
      allow(ENV).to receive(:fetch).with("CLIENT_URL", anything).and_return("https://example-app.com")
      allow(ENV).to receive(:[]).with("CLIENT_URL").and_return("https://example-app.com")
      allow(controller_instance).to receive(:params).and_return(params)
    end

    context "with trusted CLIENT_URL host" do
      let(:params) { {redirect_url: "https://example-app.com/reset"} }

      it "allows redirect" do
        expect(controller_instance.send(:redirect_options)).to eq({allow_other_host: true})
      end
    end

    context "with localhost" do
      let(:params) { {redirect_url: "http://localhost:3000/reset"} }

      it "allows redirect" do
        expect(controller_instance.send(:redirect_options)).to eq({allow_other_host: true})
      end
    end

    context "with untrusted host" do
      let(:params) { {redirect_url: "https://evil.com/phishing"} }

      it "raises error" do
        expect {
          controller_instance.send(:redirect_options)
        }.to raise_error(ActionController::BadRequest, /Unsafe redirect_url/)
      end
    end
  end
end
