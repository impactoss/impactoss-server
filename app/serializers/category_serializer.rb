class CategorySerializer < ApplicationSerializer
  attributes :title, :short_title, :description, :url, :draft, :reference, :taxonomy_id, :manager_id
end
