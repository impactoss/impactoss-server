require 'rails_helper'

RSpec.describe SdgtargetCategory, type: :model do
  it { is_expected.to belong_to :sdgtarget }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:sdgtarget_id) }
  it { is_expected.to validate_presence_of :category_id }
  it { is_expected.to validate_presence_of :sdgtarget_id }
end
