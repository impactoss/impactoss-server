# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Recommendation, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :categories }
  it { should have_many :measures }
  it { should have_many :indicators }
  it { should have_many :progress_reports }
  it { should have_many :due_dates }
end
