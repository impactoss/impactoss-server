# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Recommendation, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :categories }
  it { should have_many :measures }
  it { should have_many :indicators }
  it { should have_many :progress_reports }
  it { should have_many :due_dates }

  it 'must have at least one category' do
    @recommendation = FactoryGirl.build(:recommendation, :without_category)
    expect(@recommendation).not_to be_valid
    @recommendation.categories << FactoryGirl.create(:category)
    expect(@recommendation).to be_valid
  end

  before do
    @recommendation = FactoryGirl.create(:recommendation)
  end

  it 'remembers title and number' do
    expect(!@recommendation.title.empty?)
    expect(@recommendation.number.positive?)
  end

  it 'remembers a measure' do
    @measure = FactoryGirl.create(:measure)
    @recommendation.measures << @measure
    expect(@recommendation.measures.count == 1)
  end
end
