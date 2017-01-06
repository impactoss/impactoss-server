class MeasureCategory < ApplicationRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category
end
