# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def last_modified_user_id
    self[:last_modified_user_id] || calculate_last_modified_user_id
  end

  protected def calculate_last_modified_user_id
    return nil unless respond_to?(:versions) && versions.last
    versions.last.whodunnit
  end
end
