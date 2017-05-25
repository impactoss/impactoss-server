require 'rails_helper'

RSpec.describe SdgtargetCategory, type: :model do
  it { should belong_to :sdgtarget }
  it { should belong_to :category }
  it { should validate_uniqueness_of(:category_id).scoped_to(:sdgtarget_id) }
  it { should validate_presence_of :category_id }
  it { should validate_presence_of :sdgtarget_id }
end
