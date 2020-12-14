require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :measures }
  it { is_expected.to have_many :progress_reports }
  it { is_expected.to have_many :due_dates }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to belong_to :manager }

  context "due_date field validations" do
    let!(:indicator_with_repeat) { FactoryGirl.create(:indicator, :with_repeat) }
    let!(:indicator_without_repeat) { FactoryGirl.create(:indicator, :without_repeat) }

    it 'requires end_date only if repeat is set to true' do
      expect(indicator_with_repeat).to validate_presence_of :end_date
      expect(indicator_without_repeat).to_not validate_presence_of :end_date
    end

    it 'requires frequency_months if repeat is set to true' do
      expect(indicator_with_repeat).to validate_presence_of :frequency_months
      expect(indicator_without_repeat).to_not validate_presence_of :frequency_months
    end

    it 'requires end_date is greater than start_date if repeat is true' do
      indicator_with_repeat.end_date = indicator_with_repeat.start_date - 1.day
      expect(indicator_with_repeat).to be_invalid
      indicator_with_repeat.end_date = indicator_with_repeat.start_date + 1.day
      expect(indicator_with_repeat).to be_valid
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
    indicator.end_date = Date.today + 2.years - 15.days
    indicator.save!
    expect(indicator.due_dates.count).to be 24
    expect(indicator.due_dates.has_progress_reports.count).to be 1
    expect(indicator.due_dates.has_progress_reports.first.id).to be due_date.id
    expect(due_date.progress_reports.count).to be 1
  end
end
