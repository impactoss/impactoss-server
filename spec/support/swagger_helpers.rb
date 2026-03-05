# frozen_string_literal: true

# Shared helpers and examples for rswag API specs
#
# Usage in spec files:
#
#   require "swagger_helper"
#
#   RSpec.describe "Categories API", type: :request do
#     include_context "swagger auth helpers"
#
#     CATEGORY_CREATE_ROLES = Permissions.roles_with_permission("category", "create")
#     # ...
#
#     path "/categories" do
#       get "List categories" do
#         # ...
#       end
#
#       post "Create a category" do
#         include_examples "swagger auth parameters"
#         # ...
#         include_examples "swagger 401"
#         include_examples "swagger crud responses", "category", :create, CATEGORY_CREATE_ROLES do
#           # override lets for success/error cases if needed
#         end
#       end
#     end
#   end

# ──────────────────────────────────────────────
# Shared context: auth helpers + default lets
# ──────────────────────────────────────────────
RSpec.shared_context "swagger auth helpers" do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:manager) { FactoryBot.create(:user, :manager) }
  let(:contributor) { FactoryBot.create(:user, :contributor) }
  let(:guest) { FactoryBot.create(:user) }

  let(:"access-token") { nil }
  let(:client) { nil }
  let(:uid) { nil }

  def auth_headers_for(user)
    user.create_new_auth_token
  end

  # Returns the role name string for the lowest permitted role
  def self.lowest_role(roles)
    roles.min_by { |r| Permissions::ROLE_HIERARCHY[r] }
  end
end

# ──────────────────────────────────────────────
# Shared example: 401 not authenticated
# ──────────────────────────────────────────────
RSpec.shared_examples "swagger 401" do
  response "401", "not authenticated" do
    let(:"access-token") { "invalid" }
    let(:client) { "invalid" }
    let(:uid) { "invalid" }

    run_test!
  end
end

# ──────────────────────────────────────────────
# Shared example: 403 insufficient role (guest)
# ──────────────────────────────────────────────
RSpec.shared_examples "swagger 403 forbidden" do |description|
  response "403", description || "not authorised (insufficient role)" do
    let(:auth) { auth_headers_for(guest) }
    let(:"access-token") { auth["access-token"] }
    let(:client) { auth["client"] }
    let(:uid) { auth["uid"] }

    run_test!
  end
end

# ──────────────────────────────────────────────
# Shared example: 403 disabled (even admin)
# ──────────────────────────────────────────────
RSpec.shared_examples "swagger 403 disabled" do |resource_name, action_name|
  response "403", "forbidden - #{resource_name} #{action_name} is disabled" do
    let(:auth) { auth_headers_for(admin) }
    let(:"access-token") { auth["access-token"] }
    let(:client) { auth["client"] }
    let(:uid) { auth["uid"] }

    run_test!
  end
end
