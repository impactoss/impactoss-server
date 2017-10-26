class Sdgtarget < ApplicationRecord
  has_paper_trail

  has_many :sdgtarget_categories, inverse_of: :sdgtarget, dependent: :destroy
  has_many :sdgtarget_indicators, inverse_of: :sdgtarget, dependent: :destroy
  has_many :sdgtarget_recommendations, inverse_of: :sdgtarget, dependent: :destroy
  has_many :sdgtarget_measures, inverse_of: :sdgtarget, dependent: :destroy

  validates :reference, presence: true
  validates :title, presence: true

  default_scope { includes(:versions) }
end
