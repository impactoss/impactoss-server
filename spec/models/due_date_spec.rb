require 'rails_helper'

RSpec.describe DueDate, type: :model do
  it { should belong_to :indicator }
  it { should validate_presence_of :due_date }
  it { should have_one :manager }
  it { should have_many :progress_reports }
end
