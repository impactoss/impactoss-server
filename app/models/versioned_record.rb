require_relative "application_record"

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  after_commit :cache_updated_by_id, on: [:create, :update]
  belongs_to :updated_by, class_name: "User", required: false

  has_paper_trail

  private

  def cache_updated_by_id
    update_column(:updated_by_id, versions.last.whodunnit) if versions.last
  end
end
