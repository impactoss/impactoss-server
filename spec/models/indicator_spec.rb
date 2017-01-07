require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :measures }
  it { should have_many :progress_reports }
  it { should have_many :due_dates }
  it { should have_many :categories }
  it { should have_many :recommendations }
  it { should belong_to :manager }

  it 'must have at least one measure' do
    @indicator = FactoryGirl.build(:indicator, :without_measure)
    expect(@indicator).not_to be_valid
    @indicator.measures << FactoryGirl.create(:measure)
    expect(@indicator).to be_valid
  end
end
