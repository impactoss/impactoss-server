require_relative 'application_record'

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  after_commit :cache_last_modified_user_id

  has_paper_trail

  def last_modified_user
    return nil unless last_modified_user_id
    @last_modified_user ||= User.find(last_modified_user_id)
  end

  private

  def cache_last_modified_user_id
    update_column(:last_modified_user_id, versions.last.whodunnit) if versions.last
  end
end
