require 'rails_helper'

RSpec.describe DueDate, type: :model do
  it { is_expected.to belong_to :indicator }
  it { is_expected.to validate_presence_of :due_date }
  it { is_expected.to have_one :manager }
  it { is_expected.to have_many :progress_reports }

  it "due is true if the due date is after today but before today plus DueDate::DUE_NUMBER_OF_DAYS with no reports" do
    due_date = FactoryGirl.build(:due_date, due_date: Date.today + DueDate::DUE_NUMBER_OF_DAYS - 1.day)
    expect(due_date.due).to be_truthy
    expect(due_date.overdue).to be_falsey
  end

  it "due is false if the due date is after today but before today plus DueDate::DUE_NUMBER_OF_DAYS with a report" do
    progress_report = FactoryGirl.create(:progress_report)
    due_date = FactoryGirl.build(:due_date,
                                 due_date: Date.today + DueDate::DUE_NUMBER_OF_DAYS - 1.day,
                                 progress_reports: [progress_report])
    expect(due_date.due).to be_falsey
    expect(due_date.overdue).to be_falsey
  end

  it "overdue is false if due date is before today with a report" do
    progress_report = FactoryGirl.create(:progress_report)
    overdue_due_date = FactoryGirl.build(:due_date, due_date: Date.today - 2.days, progress_reports: [progress_report])
    expect(overdue_due_date.due).to be_falsey
    expect(overdue_due_date.overdue).to be_falsey
  end

  it "overdue is true if due date is before today with no reports" do
    overdue_due_date = FactoryGirl.build(:due_date, due_date: Date.today - 2.days)
    expect(overdue_due_date.due).to be_falsey
    expect(overdue_due_date.overdue).to be_truthy
  end

  it "due is true, overdue is false if due date is today with no reports" do
    due_today = FactoryGirl.build(:due_date, due_date: Date.today)
    expect(due_today.due).to be_truthy
    expect(due_today.overdue).to be_falsey
  end

  it "due is true if due date is today plus DueDate::DUE_NUMBER_OF_DAYS with no reports" do
    due_in_due_number_of_days = FactoryGirl.build(:due_date, due_date: Date.today + DueDate::DUE_NUMBER_OF_DAYS)
    expect(due_in_due_number_of_days.due).to be_truthy
  end

  it "overdue and due are false if the due date is after today plus DueDate::DUE_NUMBER_OF_DAYS with no reports" do
    not_due_due_date = FactoryGirl.build(:due_date, due_date: Date.today + DueDate::DUE_NUMBER_OF_DAYS + 1.month)
    expect(not_due_due_date.due).to be_falsey
    expect(not_due_due_date.overdue).to be_falsey
  end

  it "has_progress_report is true if there is a progress report" do
    progress_report = FactoryGirl.create(:progress_report)
    due_date_with_report = FactoryGirl.build(:due_date, progress_reports: [progress_report])
    expect(due_date_with_report.has_progress_report).to be_truthy
  end

  it "has_progress_report is false if there is not a progress report" do
    due_date_with_report = FactoryGirl.build(:due_date, progress_reports: [])
    expect(due_date_with_report.has_progress_report).to be_falsey
  end
end
