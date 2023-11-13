class SdgtargetCategory < ApplicationRecord
  belongs_to :sdgtarget
  belongs_to :category
  accepts_nested_attributes_for :sdgtarget
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :sdgtarget_id}
  validates :sdgtarget_id, presence: true
  validates :category_id, presence: true
end
