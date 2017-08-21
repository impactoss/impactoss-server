class SdgtargetRecommendation < ApplicationRecord
  belongs_to :sdgtarget
  belongs_to :recommendation
  accepts_nested_attributes_for :sdgtarget
  accepts_nested_attributes_for :recommendation

  validates :recommendation_id, uniqueness: { scope: :sdgtarget_id }
  validates :sdgtarget_id, presence: true
  validates :recommendation_id, presence: true
end
