require 'rails_helper'

RSpec.describe UserCategory, type: :model do
  it { should belong_to :user }
  it { should belong_to :category }
  it { should validate_uniqueness_of(:user_id).scoped_to(:category_id) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:category_id) }
end
