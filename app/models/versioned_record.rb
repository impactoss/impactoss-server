require_relative 'application_record'

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  after_commit :cache_last_modified_user_id, on: [:create, :update]
  belongs_to :last_modified_user, required: false

  has_paper_trail

  private

  def cache_last_modified_user_id
    update_column(:last_modified_user_id, versions.last.whodunnit) if versions.last
  end
end
