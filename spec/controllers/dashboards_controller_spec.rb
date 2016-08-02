# frozen_string_literal: true
require "rails_helper"

RSpec.describe DashboardsController, type: :controller do
  describe "GET show" do
    subject { get(:show) }
    before { sign_in }
    it { expect(subject).to be_ok }
  end
end
