require_relative "application_record"

class VersionedRecord < ApplicationRecord
  self.abstract_class = true

  after_commit :cache_updated_by_id, on: [:create, :update], if: :cache_updated_by_id?
  belongs_to :updated_by, class_name: "User", required: false

  def self.inherited(base)
    if base.name == "User"
      sensitive = %w[
        encrypted_password tokens reset_password_token
        otp_secret multi_factor_email_code multi_factor_email_code_sent_at
        confirmation_token
      ]

      base.has_paper_trail(
        only: [
          :id, :email, :name, :provider, :uid,
          :created_at, :updated_at, :sign_in_count,
          :current_sign_in_at, :last_sign_in_at,
          :current_sign_in_ip, :last_sign_in_ip,
          :updated_by_id, :created_by_id,
          :relationship_updated_at, :relationship_updated_by_id,
          :failed_attempts, :locked_at,
          :password_changed_at, :confirmed_at,
          :otp_required_for_login, :allow_password_change,
          :remember_created_at, :reset_password_sent_at
        ]
      )

      # Strip sensitive data from the serialized object
      base.define_method(:object_attrs_for_paper_trail) do |attributes|
        attributes.except(*sensitive)
      end
    else
      base.has_paper_trail ignore: []
    end

    super
  end

  private def cache_updated_by_id
    update_column(:updated_by_id, PaperTrail.request.whodunnit)
  end

  private def cache_updated_by_id?
    !PaperTrail.request.whodunnit.nil? &&
      self.class.column_names.include?("updated_by_id")
  end
end
