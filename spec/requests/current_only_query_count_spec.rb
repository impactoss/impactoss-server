# frozen_string_literal: true

require "rails_helper"

# CurrentCycle exists to replace an N+1 (see app/models/current_cycle.rb) with
# a fixed number of queries, independent of how many records exist. That
# independence is the property none of the functional specs can catch - a
# serialiser change, an added association, or a stray is_current call in a
# mailer can silently reinstate the N+1 while every other test stays green.
# Asserted as equality across two fixture sizes rather than a ceiling: an O(n)
# regression with a small constant would still fit under a fixed ceiling at
# ten records, and a ceiling would need re-tuning every time an unrelated
# query is added to the request.
RSpec.describe "current_only query count", type: :request do
  let(:admin) { FactoryBot.create(:user, :admin) }

  let(:parent_taxonomy) { FactoryBot.create(:taxonomy) }
  let(:cycle_taxonomy) { FactoryBot.create(:taxonomy, taxonomy: parent_taxonomy) }
  let!(:treaty) { FactoryBot.create(:category, taxonomy: parent_taxonomy, draft: false) }
  let!(:current_cycle) do
    FactoryBot.create(:category, taxonomy: cycle_taxonomy, parent_id: treaty.id,
      draft: false, date: Date.new(2025, 1, 1))
  end
  let!(:stale_cycle) do
    FactoryBot.create(:category, taxonomy: cycle_taxonomy, parent_id: treaty.id,
      draft: false, date: Date.new(2020, 1, 1))
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

  # Half the recommendations under the current cycle, half under the stale
  # one, each with its own measure, indicator and progress report - so both
  # the current and non-current id sets are non-trivial.
  def build_fixture(size)
    size.times do |i|
      cycle = i.even? ? current_cycle : stale_cycle
      recommendation = FactoryBot.create(:recommendation)
      recommendation.categories = [cycle]
      measure = FactoryBot.create(:measure)
      measure.recommendations = [recommendation]
      indicator = FactoryBot.create(:indicator)
      indicator.measures = [measure]
      due_date = FactoryBot.create(:due_date, indicator:)
      FactoryBot.create(:progress_report, indicator:, due_date:)
    end
  end

  def query_count_for(path)
    count_queries { get path, params: {current_only: "true"}, headers: @headers }
  end

  %w[/recommendations /measures /indicators /progress_reports].each do |path|
    it "resolves #{path} current_only in a record-count-independent number of queries" do
      build_fixture(10)
      small = query_count_for(path)
      expect(response).to have_http_status(:success)

      build_fixture(30)
      large = query_count_for(path)
      expect(response).to have_http_status(:success)

      expect(large).to eq(small)
    end
  end
end
