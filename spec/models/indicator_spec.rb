require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it { should validate_presence_of :title }
  it { should have_many :measures }
  it { should have_many :progress_reports }
  it { should have_many :due_dates }
  it { should have_many :categories }
  it { should have_many :recommendations }
  it { should belong_to :manager }

  context "due_date field validations" do
    it 'requires end_date if repeat is set to true' do
      indicator_with_repeat = FactoryGirl.build(:indicator, :with_repeat)
      indicator_with_repeat.should validate_presence_of :end_date
      indicator_without_repeat = FactoryGirl.build(:indicator, :without_repeat)
      indicator_without_repeat.should_not validate_presence_of :end_date
    end

    it 'requires frequency_months if repeat is set to true' do
      indicator_with_repeat = FactoryGirl.build(:indicator, :with_repeat)
      indicator_with_repeat.should validate_presence_of :frequency_months
      indicator_without_repeat = FactoryGirl.build(:indicator, :without_repeat)
      indicator_without_repeat.should_not validate_presence_of :frequency_months
    end

    it 'requires end_date is greater than start_date if repeat is true' do
      indicator_with_repeat = FactoryGirl.build(:indicator, :with_repeat)
      indicator_with_repeat.end_date = indicator_with_repeat.start_date - 1.day
      indicator_with_repeat.should be_invalid
      indicator_with_repeat.end_date = indicator_with_repeat.start_date + 1.day
      indicator_with_repeat.should be_valid
    end
  end

  it "builds due_dates" do
    indicator = FactoryGirl.create(:indicator, :with_12_due_dates)
    expect(indicator.due_dates.count).to be 12
  end

  it "builds one due_date for non repeating indicators" do
    indicator = FactoryGirl.create(:indicator, :without_repeat)
    expect(indicator.due_dates.count).to be 1
  end

  it "does not delete due_dates that have progress_reports on update" do
    indicator = FactoryGirl.create(:indicator, :with_12_due_dates)
    due_date = indicator.due_dates.last
    progress_report = due_date.progress_reports.create!(indicator: indicator, title: 'test')
    expect(indicator.due_dates.count).to be 12
    indicator.end_date = Date.today + 2.years - 1.days
    indicator.save!
    expect(indicator.due_dates.count).to be 24
    expect(indicator.due_dates.has_progress_reports.count).to be 1
    expect(indicator.due_dates.has_progress_reports.first.id).to be due_date.id
    expect(due_date.progress_reports.count).to be 1
  end
end
