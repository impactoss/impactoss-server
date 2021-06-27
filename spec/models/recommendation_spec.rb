# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Recommendation, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :reference }
  
  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :measures }
  it { is_expected.to have_many :indicators }
  it { is_expected.to have_many :progress_reports }
  it { is_expected.to have_many :due_dates }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :recommendation_recommendations }
  it { is_expected.to have_many :recommendation_categories }
  it { is_expected.to have_many :recommendation_measures }
  it { is_expected.to have_many :sdgtarget_recommendations }
  it { is_expected.to have_many :recommendation_indicators }

  it { is_expected.to belong_to(:framework).optional }

  it { is_expected.to accept_nested_attributes_for :recommendation_categories}
end
