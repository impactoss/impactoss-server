# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def last_modified_user_id
    return nil unless respond_to? :versions
    return nil unless versions.last
    versions.last.whodunnit
  end

  def last_modified_user
    return nil unless last_modified_user_id
    User.find last_modified_user_id
  end
end
