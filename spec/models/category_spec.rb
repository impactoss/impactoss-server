require 'rails_helper'

RSpec.describe Category, type: :model do
  it { should validate_presence_of :title }
  it { should belong_to :taxonomy }
  it { should belong_to :manager }
  it { should have_many :recommendations }
  it { should have_many :users }
  it { should have_many :measures }
  it { should have_many :indicators }
  it { should have_many :progress_reports }
  it { should have_many :due_dates }
end
