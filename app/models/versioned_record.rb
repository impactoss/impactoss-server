require_relative 'application_record'

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  has_paper_trail

  def last_modified_user
    return nil unless last_modified_user_id
    @last_modified_user ||= User.find(last_modified_user_id)
  end

  scope :with_versions, -> do
    left_outer_joins(:versions).select(
      "#{quoted_table_name}.*",
      "#{::PaperTrail::Version.quoted_table_name}.whodunnit AS last_modified_user_id"
    )
  end
end
