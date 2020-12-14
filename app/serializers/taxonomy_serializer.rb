class TaxonomySerializer
  include FastApplicationSerializer

  attributes :title, :parent_id, :tags_recommendations, :tags_measures, :tags_users, :allow_multiple, :has_manager, :priority, :tags_sdgtargets, :is_smart, :groups_measures_default, :groups_recommendations_default, :has_date, :groups_sdgtargets_default

  set_type :taxonomies
end
