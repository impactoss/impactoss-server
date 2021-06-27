require 'rails_helper'

RSpec.describe UserRole, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :role }
  # it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:role_id) }
end
