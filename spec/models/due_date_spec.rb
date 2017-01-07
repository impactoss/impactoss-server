require 'rails_helper'

RSpec.describe DueDate, type: :model do
  it { should belong_to :indicator }
  it { should validate_presence_of :due_date }
end
