class Sdgtarget < ApplicationRecord
  has_paper_trail

  validates :reference, presence: true
  validates :title, presence: true
end
