# frozen_string_literal: true
require "rails_helper"

RSpec.describe DashboardsController, type: :controller do
  describe "GET show" do
    subject { get(:show) }
    it { expect(subject).to be_ok }
  end
end
