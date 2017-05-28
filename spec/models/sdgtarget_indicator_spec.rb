require 'rails_helper'

RSpec.describe SdgtargetIndicator, type: :model do
  it { should belong_to :sdgtarget }
  it { should belong_to :indicator }
  it { should validate_uniqueness_of(:indicator_id).scoped_to(:sdgtarget_id) }
  it { should validate_presence_of :indicator_id }
  it { should validate_presence_of :sdgtarget_id }
end
