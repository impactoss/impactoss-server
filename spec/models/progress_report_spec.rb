require 'rails_helper'

RSpec.describe ProgressReport, type: :model do
  it { is_expected.to belong_to :indicator }
  it { is_expected.to belong_to(:due_date).optional }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :measures }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_one :manager }
  it { is_expected.to validate_presence_of(:indicator_id) }
end
