# frozen_string_literal: true
require "rails_helper"

RSpec.describe Action, type: :model do
  before do
    @action = FactoryGirl.create(:action)
  end

  it "remembers title and description" do
    expect(!@action.title.empty?)
    expect(!@action.description.empty?)
    expect(!@action.target_date.empty?)
  end

  it "remembers a recommendation" do
    @recommendation = FactoryGirl.create(:recommendation)
    @action.recommendations << @recommendation
    expect(@action.recommendations.count == 1)
  end

  it "enforces required fields" do
    @broken_action = Action.new
    expect { @broken_action.save }.to raise_error ActiveRecord::StatementInvalid

    @broken_action.title = "Test"
    expect { @broken_action.save }.to_not raise_error
  end
end
