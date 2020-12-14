require 'rails_helper'

RSpec.describe Role, type: :model do
  it { is_expected.to have_many :user_roles }
  it { is_expected.to have_many :users }
end
