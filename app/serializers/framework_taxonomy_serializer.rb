class FrameworkTaxonomySerializer
  include FastApplicationSerializer

  attributes :framework_id, :taxonomy_id

  set_type :framework_taxonomies
end
