require 'rails_helper'

RSpec.describe Measure, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :indicators }
  it { is_expected.to have_many :due_dates }
  it { is_expected.to have_many :progress_reports }
end
