class FrameworkTaxonomySerializer
  include FastVersionedSerializer

  attributes :framework_id, :taxonomy_id

  set_type :frameworks_taxonomies
end
