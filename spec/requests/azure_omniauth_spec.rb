# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Azure AD sign in", type: :request do
  let(:provider) { :azure_activedirectory_v2 }
  let(:origin) { "http://client.example.com/login" }
  let(:groups) { [] }
  let(:info) { {email: "jane.doe@example.com", first_name: "Jane", last_name: "Doe", name: "Jane Doe"} }

  # ApplicationController's `only:` callbacks (authenticate_user!, verify_policy_scoped) name
  # actions this controller doesn't have. Production has raise_on_missing_callback_actions off,
  # so run the flow under the same setting rather than the dev/test default.
  around do |example|
    original = ActionController::Base.raise_on_missing_callback_actions
    ActionController::Base.raise_on_missing_callback_actions = false
    example.run
  ensure
    ActionController::Base.raise_on_missing_callback_actions = original
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("AZURE_GROUP_ADMIN").and_return("group-admin")
    allow(ENV).to receive(:[]).with("AZURE_GROUP_MANAGER").and_return("group-manager")
    allow(ENV).to receive(:[]).with("AZURE_GROUP_CONTRIBUTOR").and_return("group-contributor")

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      provider: provider.to_s,
      uid: "azure-uid-123",
      info: info,
      extra: {raw_info: {groups: groups}}
    )
  end

  after do
    OmniAuth.config.mock_auth.delete(provider)
    OmniAuth.config.test_mode = false
  end

  def sign_in_with_azure
    get "/auth/#{provider}", params: {auth_origin_url: origin, resource_class: "User"}
    expect(response).to redirect_to(%r{/auth/azure_oauth2/callback})
    follow_redirect!
    expect(response.location.to_s).to start_with(origin),
      "callback returned #{response.status} (location: #{response.location.inspect})\n#{response.body.to_s[0, 2000]}"
  end

  let(:signed_in_user) { User.find_by(uid: "azure-uid-123", provider: provider.to_s) }

  it "creates the user and redirects back to the client with a token" do
    expect { sign_in_with_azure }.to change(User, :count).by(1)

    expect(response).to have_http_status(:redirect)
    expect(response.location).to start_with(origin)
    expect(response.location).to include("auth_token=")
    expect(signed_in_user.email).to eq("jane.doe@example.com")
  end

  describe "user name" do
    subject(:saved_name) do
      sign_in_with_azure
      signed_in_user.name
    end

    context "with first and last name" do
      let(:info) { {email: "jane.doe@example.com", first_name: "Jane", last_name: "Doe", name: "Display Name"} }

      it { is_expected.to eq("Jane Doe") }
    end

    context "with only a first name" do
      let(:info) { {email: "jane.doe@example.com", first_name: "Jane", name: "Display Name"} }

      it { is_expected.to eq("Jane") }
    end

    context "without first or last name" do
      let(:info) { {email: "jane.doe@example.com", first_name: "", last_name: nil, name: "Display Name"} }

      it("falls back to the display name") { is_expected.to eq("Display Name") }
    end

    context "without any name" do
      let(:info) { {email: "jane.doe@example.com"} }

      it("falls back to the email") { is_expected.to eq("jane.doe@example.com") }
    end
  end

  describe "roles from Azure groups" do
    let!(:admin) { FactoryBot.create(:role, :admin) }
    let!(:manager) { FactoryBot.create(:role, :manager) }
    let!(:contributor) { FactoryBot.create(:role, :contributor) }

    context "with matching groups" do
      let(:groups) { ["group-admin", "group-contributor", "unrelated-group"] }

      it "assigns the mapped roles" do
        sign_in_with_azure
        expect(signed_in_user.roles).to contain_exactly(admin, contributor)
      end
    end

    context "without matching groups" do
      let(:groups) { ["unrelated-group"] }

      it "assigns no roles" do
        sign_in_with_azure
        expect(signed_in_user.roles).to be_empty
      end
    end

    context "when the user's groups change" do
      let(:groups) { ["group-manager"] }

      it "replaces the previous roles on the next sign in" do
        FactoryBot.create(:user, uid: "azure-uid-123", provider: provider.to_s, email: "jane.doe@example.com", roles: [admin])

        sign_in_with_azure
        expect(signed_in_user.roles).to contain_exactly(manager)
      end
    end
  end
end
