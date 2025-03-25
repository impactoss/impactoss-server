require_relative "application_record"

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  after_commit :cache_updated_by_id, on: [:create, :update], if: :cache_updated_by_id?
  belongs_to :updated_by, class_name: "User", required: false

  def self.paper_trail_ignored_columns = []

  has_paper_trail ignore: paper_trail_ignored_columns

  private

  def cache_updated_by_id
    update_column(:updated_by_id, PaperTrail.request.whodunnit)
  end

  def cache_updated_by_id?
    !PaperTrail.request.whodunnit.nil? &&
      self.class.column_names.include?("updated_by_id")
  end
end
