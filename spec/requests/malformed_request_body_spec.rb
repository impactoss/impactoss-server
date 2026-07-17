require "rails_helper"

RSpec.describe "Malformed request body handling", type: :request do
  # malformed body is rejected in params parsing, before authenticate_user!, so no auth needed
  it "returns 400 for an unparseable JSON body" do
    post "/bookmarks",
      params: '{ "bookmark": { "title": "x", "view": {not valid json} } }',
      headers: {"Content-Type" => "application/json"}

    expect(response).to have_http_status(:bad_request)
  end
end
