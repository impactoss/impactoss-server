if Features.enabled?(:progress_reports)
  RSpec.describe "Due Dates API", type: :request do
    include_context "swagger auth helpers"

    path "/due_dates" do
      get "List due dates" do
        tags "Due Dates"
        produces "application/json"
        security [{access_token: [], client: [], uid: []}]

        response "200", "returns due dates (requires manager+)" do
          let(:auth) { auth_headers_for(manager) }
          let(:"access-token") { auth["access-token"] }
          let(:client) { auth["client"] }
          let(:uid) { auth["uid"] }

          before do
            FactoryBot.create(:due_date)
          end

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json["data"].length).to eq(1)
          end
        end
      end
    end
  end
end
