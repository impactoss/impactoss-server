# frozen_string_literal: true

# Resolves, once per request, which records are current with respect to the
# reporting cycle taxonomy.
#
# is_current is a property of the whole graph, not of one record:
#
#   ProgressReport -> indicator -> measures -> recommendations -> categories
#
# Evaluated per record it is an N+1 at every hop, and because is_current is
# also a serialiser attribute it runs twice per request - once to filter and
# again to serialise. This resolves the id sets in a fixed number of queries
# instead, independent of how many records exist.
#
# It deliberately does NOT reimplement Category#is_current. Its sibling
# comparison is not scoped to the cycle taxonomy - has_many :categories is
# keyed on parent_id alone - so a rewrite that "obviously" scoped it would
# change an answer nobody has characterised, in a comparison that is subtle
# and easy to get wrong. No current deployment's taxonomy has more than one
# child under a parent, so the unscoped comparison cannot currently change
# an outcome, but that is a fact about today's data, not the code, and isn't
# a safe thing to build a rewrite on. It is called exactly as it stands,
# once per cycle category (a handful) rather than once per recommendation
# (thousands). Only the trivial "empty? || any?" propagation above it is
# resolved set-wise.
class CurrentCycle
  def recommendation_current?(id)
    !non_current_recommendation_ids.include?(id)
  end

  def measure_current?(id)
    !non_current_measure_ids.include?(id)
  end

  # A nil id (a ProgressReport with no indicator) is treated as non-current,
  # unconditionally - including when stale_ids is empty. The controller's
  # filter has to exclude a null indicator_id explicitly to agree: plain
  # `where.not(indicator_id: stale_ids)` compiles to `1=1` when stale_ids is
  # empty (every cycle dated and current, the common case), which would let a
  # null indicator_id through. See ProgressReportsController#base_object.
  def indicator_current?(id)
    id.present? && !non_current_indicator_ids.include?(id)
  end

  # Recommendations linked to at least one reporting-cycle category, none of
  # which is current. Anything else is current, including a recommendation
  # linked to no cycle category at all. The scope is restricted to cycle
  # categories, so an unrelated category cannot rescue a stale recommendation.
  def non_current_recommendation_ids
    @non_current_recommendation_ids ||=
      stale_parents(RecommendationCategory.where(category_id: cycle_category_ids.to_a),
        :recommendation_id, :category_id, stale_category_ids)
  end

  # A measure is current when it has no recommendations, or any is current.
  def non_current_measure_ids
    @non_current_measure_ids ||=
      stale_parents(RecommendationMeasure.all, :measure_id, :recommendation_id,
        non_current_recommendation_ids)
  end

  # An indicator is current when it has no measures, or any is current.
  def non_current_indicator_ids
    @non_current_indicator_ids ||=
      stale_parents(MeasureIndicator.all, :indicator_id, :measure_id,
        non_current_measure_ids)
  end

  private

  def cycle_categories
    @cycle_categories ||= Category.where(taxonomy_id: Taxonomy.current_reporting_cycle_id).to_a
  end

  def cycle_category_ids
    @cycle_category_ids ||= cycle_categories.map(&:id).to_set
  end

  # The one place the real predicate runs, once per cycle category.
  def current_category_ids
    @current_category_ids ||= cycle_categories.select(&:is_current).map(&:id).to_set
  end

  # Parents whose every child is stale. Only rows touching a stale child can
  # produce one, and a parent is spared as soon as it has a child outside that
  # set, so neither query reads more of the join table than the stale set
  # reaches. A parent with no children at all appears in neither, so it is
  # absent from the result and therefore current - the "empty? ||" half of the
  # rule at each level.
  #
  # A null foreign key is not a child: it cannot make a parent stale, and it
  # cannot spare one. That matches the associations these replace, where a
  # join row with a null id yields no record.
  def stale_parents(scope, parent_key, child_key, stale_child_ids)
    return Set.new if stale_child_ids.empty?

    stale = stale_child_ids.to_a
    candidates = scope.where(child_key => stale).distinct.pluck(parent_key).compact
    return Set.new if candidates.empty?

    spared = scope.where(parent_key => candidates).where.not(child_key => stale).distinct.pluck(parent_key)

    candidates.to_set - spared
  end

  # Cycle categories that lost to a sibling, or never qualified.
  def stale_category_ids
    cycle_category_ids - current_category_ids
  end
end
