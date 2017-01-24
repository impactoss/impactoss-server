class MeasureCategory < ApplicationRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: { scope: :measure_id }
  validates :measure_id, presence: true
  validates :category_id, presence: true
end
