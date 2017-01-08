require 'rails_helper'

RSpec.describe UserRole, type: :model do
  it { should belong_to :user }
  it { should belong_to :role }
  # it { should validate_uniqueness_of(:user_id).scoped_to(:role_id) }
end
