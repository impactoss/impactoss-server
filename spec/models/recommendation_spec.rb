# frozen_string_literal: true
require "rails_helper"

RSpec.describe Recommendation, type: :model do
  before do
    @recommendation = FactoryGirl.create(:recommendation)
  end

  it "remembers title and number" do
    expect(!@recommendation.title.empty?)
    expect(@recommendation.number > 0)
  end

  it "remembers an action" do
    @action = FactoryGirl.create(:action)
    @recommendation.actions << @action
    expect(@recommendation.actions.count == 1)
  end

  it "enforces required fields" do
    @broken_recommendation = Recommendation.new
    expect { @broken_recommendation.save }.to raise_error ActiveRecord::StatementInvalid

    @broken_recommendation.title = "Test"
    expect { @broken_recommendation.save }.to raise_error ActiveRecord::StatementInvalid

    @broken_recommendation.number = 1
    expect { @broken_recommendation.save }.to_not raise_error
  end
end
