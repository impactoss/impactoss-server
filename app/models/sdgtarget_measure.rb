class SdgtargetMeasure < ApplicationRecord
  belongs_to :sdgtarget
  belongs_to :measure
  accepts_nested_attributes_for :sdgtarget
  accepts_nested_attributes_for :measure

  validates :measure_id, uniqueness: { scope: :sdgtarget_id }
  validates :sdgtarget_id, presence: true
  validates :measure_id, presence: true
end
