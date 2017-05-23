class CategorySerializer < ApplicationSerializer
  attributes :title, :short_title, :description, :url, :draft, :number, :taxonomy_id, :manager_id
end
