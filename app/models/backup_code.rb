# frozen_string_literal: true

##
# Backup codes for TOTP recovery.
#
# Backup codes allow users to regain access to their account if they lose
# their TOTP device. Each code can only be used once.
class BackupCode < ApplicationRecord
  belongs_to :user

  validates :code_digest, presence: true

  ##
  # Generates a set of backup codes for a user.
  #
  # @param user [User] the user to generate codes for
  # @param count [Integer] number of codes to generate (default: 10)
  # @return [Array<String>] array of plain-text backup codes
  def self.generate_for_user(user, count: 10)
    # Delete existing codes
    user.backup_codes.destroy_all

    codes = []
    count.times do
      # Generate 8-character code (e.g., "a1b2c3d4")
      code = SecureRandom.alphanumeric(8).downcase
      codes << code

      # Store hashed version
      create!(
        user: user,
        code_digest: BCrypt::Password.create(code, cost: Devise.stretches)
      )
    end

    codes
  end

  ##
  # Validates and consumes a backup code.
  #
  # @param user [User] the user attempting to use the code
  # @param code_attempt [String] the backup code to validate
  # @return [Boolean] true if valid and unused, false otherwise
  def self.use_code(user, code_attempt)
    return false if code_attempt.blank?

    user.backup_codes.where(used_at: nil).find_each do |backup_code|
      db_pass = BCrypt::Password.new(backup_code.code_digest)
      if db_pass == code_attempt.downcase
        backup_code.update!(used_at: Time.current)
        return true
      end
    end

    false
  end

  ##
  # Returns the count of unused backup codes for a user.
  #
  # @return [Integer] number of unused codes
  def self.remaining_count(user)
    user.backup_codes.where(used_at: nil).count
  end
end
