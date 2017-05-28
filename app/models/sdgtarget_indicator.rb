class SdgtargetIndicator < ApplicationRecord
  belongs_to :sdgtarget
  belongs_to :indicator
  accepts_nested_attributes_for :sdgtarget
  accepts_nested_attributes_for :indicator

  validates :indicator_id, uniqueness: { scope: :sdgtarget_id }
  validates :sdgtarget_id, presence: true
  validates :indicator_id, presence: true
end
