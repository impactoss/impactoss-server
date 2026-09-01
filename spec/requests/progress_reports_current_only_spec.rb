# frozen_string_literal: true

require "rails_helper"

# CurrentCycle#indicator_current?(nil) says a no-indicator ProgressReport is
# non-current unconditionally, but the controller's filter used to agree only
# when the stale set was non-empty - `where.not(indicator_id: [])` compiles to
# `1=1` and lets a null indicator_id through. Every cycle being dated and
# current (empty stale set) is the common case, so this is the path that
# matters in production.
RSpec.describe "ProgressReports current_only", type: :request do
  let(:admin) { FactoryBot.create(:user, :admin) }

  let(:parent_taxonomy) { FactoryBot.create(:taxonomy) }
  let(:cycle_taxonomy) { FactoryBot.create(:taxonomy, taxonomy: parent_taxonomy) }
  let!(:treaty) { FactoryBot.create(:category, taxonomy: parent_taxonomy, draft: false) }
  let!(:current_cycle) do
    FactoryBot.create(:category, taxonomy: cycle_taxonomy, parent_id: treaty.id,
      draft: false, date: Date.new(2025, 1, 1))
  end

  before do
    allow(Rails.application.config.x)
      .to receive(:reporting_cycle_taxonomy_id)
      .and_return(cycle_taxonomy.id)

    allow(Rails.application.config).to receive(:enable_mfa).and_return(false)
    post "/auth/sign_in", params: {email: admin.email, password: "SecurePassword123!"}, as: :json
    @headers = {
      "access-token" => response.headers["access-token"],
      "client" => response.headers["client"],
      "uid" => response.headers["uid"]
    }
  end

  it "excludes a null indicator_id even when the stale set is empty" do
    # Every recommendation is under the (only, current) cycle, so
    # non_current_indicator_ids is empty - the case where the naive filter
    # degenerates to 1=1.
    indicator = FactoryBot.create(:indicator)
    recommendation = FactoryBot.create(:recommendation)
    recommendation.categories = [current_cycle]
    measure = FactoryBot.create(:measure)
    measure.recommendations = [recommendation]
    indicator.measures = [measure]
    due_date = FactoryBot.create(:due_date, indicator:)

    orphan = FactoryBot.create(:progress_report, indicator:, due_date:)
    orphan.update_column(:indicator_id, nil)

    get "/progress_reports", params: {current_only: "true"}, headers: @headers
    expect(response).to have_http_status(:success)

    ids = JSON.parse(response.body)["data"].map { |r| r["id"].to_i }
    expect(ids).not_to include(orphan.id)
  end
end
