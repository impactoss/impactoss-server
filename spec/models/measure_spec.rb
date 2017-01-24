require 'rails_helper'

RSpec.describe Measure, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :recommendations }
  it { should have_many :categories }
  it { should have_many :indicators }
  it { should have_many :due_dates }
  it { should have_many :progress_reports }
end
