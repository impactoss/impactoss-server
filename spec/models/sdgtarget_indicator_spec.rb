require 'rails_helper'

RSpec.describe SdgtargetIndicator, type: :model do
  it { is_expected.to belong_to :sdgtarget }
  it { is_expected.to belong_to :indicator }
  it { is_expected.to validate_uniqueness_of(:indicator_id).scoped_to(:sdgtarget_id) }
  it { is_expected.to validate_presence_of :indicator_id }
  it { is_expected.to validate_presence_of :sdgtarget_id }
end
