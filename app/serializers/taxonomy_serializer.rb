class TaxonomySerializer
  include FastApplicationSerializer

  attributes :title, :tags_measures, :tags_users, :allow_multiple, :has_manager, :priority, :is_smart, :groups_measures_default, :groups_recommendations_default, :groups_sdgtargets_default, :framework_id, :parent_id, :has_date

  set_type :taxonomies
end
