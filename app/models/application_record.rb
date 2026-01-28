# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_commit :cache_created_by_id, on: [:create], if: :cache_created_by_id?
  belongs_to :created_by, class_name: "User", required: false

  private

  def cache_created_by_id
    update_column(:created_by_id, ::PaperTrail.request.whodunnit)
  end

  def cache_created_by_id?
    !::PaperTrail.request.whodunnit.nil? &&
      self.class.column_names.include?("created_by_id")
  end
end
