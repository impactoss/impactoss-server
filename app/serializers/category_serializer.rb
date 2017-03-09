class CategorySerializer < ApplicationSerializer
  attributes :title, :short_title, :description, :url, :draft, :taxonomy_id
end
