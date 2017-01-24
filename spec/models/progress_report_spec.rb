require 'rails_helper'

RSpec.describe ProgressReport, type: :model do
  it { should belong_to :indicator }
  it { should belong_to :due_date }
  it { should validate_presence_of :title }
  it { should have_many :measures }
  it { should have_many :recommendations }
  it { should have_many :categories }
  it { should have_one :manager }
  it { should validate_presence_of(:indicator_id) }
end
