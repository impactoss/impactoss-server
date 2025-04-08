require_relative "application_record"

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  after_commit :cache_updated_by_id, on: [:create, :update], if: :cache_updated_by_id?
  belongs_to :updated_by, class_name: "User", required: false

  def self.inherited(base)
    ignore = case base.name
    in "User"
      [:tokens, :updated_at]
    else
      []
    end

    base.has_paper_trail ignore: ignore

    super
  end

  private def cache_updated_by_id
    update_column(:updated_by_id, PaperTrail.request.whodunnit)
  end

  private def cache_updated_by_id?
    !PaperTrail.request.whodunnit.nil? &&
      self.class.column_names.include?("updated_by_id")
  end
end
