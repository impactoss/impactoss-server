require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :measures }
  it { should have_many :progress_reports }
  it { should have_many :due_dates }
  it { should have_many :categories }
  it { should have_many :recommendations }
  it { should belong_to :manager }
end
