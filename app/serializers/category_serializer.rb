class CategorySerializer < ApplicationSerializer
  attributes :title, :short_title, :description, :url, :draft

  has_one :taxonomy
end
