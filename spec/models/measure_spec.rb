require 'rails_helper'

RSpec.describe Measure, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :recommendations }
  it { should have_many :categories }
  it { should have_many :indicators }
  it { should have_many :due_dates }
  it { should have_many :progress_reports }

  it 'must have at least one recommendation' do
    @measure = FactoryGirl.build(:measure, :without_recommendation)
    expect(@measure).not_to be_valid
    @measure.recommendations << FactoryGirl.create(:recommendation)
    expect(@measure).to be_valid
  end

  it 'must have at least one category' do
    @measure = FactoryGirl.build(:measure, :without_category)
    expect(@measure).not_to be_valid
    @measure.categories << FactoryGirl.create(:category)
    expect(@measure).to be_valid
  end
end
