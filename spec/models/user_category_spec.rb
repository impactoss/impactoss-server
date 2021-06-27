require 'rails_helper'

RSpec.describe UserCategory, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:category_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:category_id) }
end
