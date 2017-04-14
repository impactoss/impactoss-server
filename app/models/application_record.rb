# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  attr_accessor :last_updated_at_store

  validate :not_updated_since_load, on: :update

  def last_modified_user_id
    return nil unless respond_to? :versions
    return nil unless versions.last
    versions.last.whodunnit
  end

  def last_modified_user
    return nil unless last_modified_user_id
    User.find last_modified_user_id
  end

  def last_updated_at
    last_updated_at_store || updated_at
  end

  def last_updated_at=(value)
    return unless value.is_a?(String)
    return self.last_updated_at_store = DateTime.new if value.empty?
    self.last_updated_at_store = DateTime.parse(value)
  end

  private

  def not_updated_since_load
    unless last_updated_at.to_i == updated_at.to_datetime.to_i
      errors.add(:last_updated_at, "another update was performed on the server, please refresh")
    end
  end
end
