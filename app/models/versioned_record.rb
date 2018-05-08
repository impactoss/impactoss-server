require_relative 'application_record'

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  has_paper_trail

  def last_modified_user
    return nil unless last_modified_user_id
    @last_modified_user ||= User.find(last_modified_user_id)
  end

  scope :with_versions, -> do
    select(
      "#{quoted_table_name}.*," \
      "(SELECT whodunnit FROM #{::PaperTrail::Version.quoted_table_name} " \
      "WHERE #{::PaperTrail::Version.quoted_table_name}.item_type = '#{self.base_class.name}' " \
      "AND #{::PaperTrail::Version.quoted_table_name}.item_id = #{quoted_table_name}.id " \
      "ORDER BY #{::PaperTrail::Version.quoted_table_name}.created_at DESC " \
      "LIMIT 1) last_modified_user_id"
    )
  end
end
