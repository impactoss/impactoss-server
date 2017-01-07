require 'rails_helper'

RSpec.describe UserCategory, type: :model do
  it { should belong_to :user }
  it { should belong_to :category }
end
