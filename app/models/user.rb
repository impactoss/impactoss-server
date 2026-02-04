# frozen_string_literal: true

class User < VersionedRecord
  #  :omniauthable
  include DeviseTokenAuth::Concerns::User

  # Include default devise modules with security extensions
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # Added: :lockable, :password_expirable, :password_archivable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :lockable, :password_expirable, :password_archivable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :managed_categories, foreign_key: :manager_id, class_name: "Category"
  has_many :managed_indicators, foreign_key: :manager_id, class_name: "Indicator"
  has_many :user_categories
  has_many :categories, through: :user_categories
  has_many :bookmarks
  has_many :backup_codes, dependent: :destroy

  belongs_to :relationship_updated_by, class_name: "User", required: false

  # Encrypt TOTP secret at rest
  encrypts :otp_secret, deterministic: false

  validates :email, presence: true
  validates :name, presence: true

  # secure password validation
  validates :password, secure_password: true, if: :password_required?

  # Track date of password change for expiry feature
  before_update :set_password_changed_at, if: :saved_change_to_encrypted_password?

  # Override Devise's confirmable methods to disable email confirmation
  # DeviseTokenAuth 1.2.5+ appears to use confirmable even when disabled
  def confirmed?
    true # All users are always "confirmed"
  end

  def confirmation_required?
    false # Never require confirmation
  end

  def active_for_authentication?
    super # Use default behavior (doesn't check confirmation)
  end

  def has_any_role?(role_names)
    return false if roles.empty?

    role_names.any? do |role_name|
      if Permissions::ROLE_HIERARCHY.key?(role_name)
        role?(role_name)
      else
        roles.exists?(name: role_name)
      end
    end
  end

  def role?(role_name)
    # For hierarchical roles, check level
    if Permissions::ROLE_HIERARCHY.key?(role_name)
      required_level = Permissions::ROLE_HIERARCHY[role_name]

      roles.any? do |user_role|
        user_level = Permissions::ROLE_HIERARCHY[user_role.name]
        user_level && user_level >= required_level
      end
    else
      # For non-hierarchical roles (or roles not in hierarchy), check exact match
      roles.exists?(name: role_name)
    end
  end

  def domain
    email.to_s.split("@").last
  end

  # Multi-factor authentication methods

  ##
  # Generates a 6-digit OTP code, stores it encrypted in the database,
  # and sends it to the user's email address.
  #
  # The OTP code is hashed using BCrypt before storage to prevent
  # exposure if the database is compromised. The code expires after
  # 10 minutes (see #multi_factor_email_code_expired?).
  #
  # @return [String] the generated 6-digit OTP code (for testing purposes)
  # @example
  #   user.generate_and_send_multi_factor_email!
  #   # => "123456"
  def generate_and_send_multi_factor_email!
    six_digit_string = SecureRandom.random_number(10**6).to_s.rjust(6, "0")
    update_columns(
      multi_factor_email_code: BCrypt::Password.create(six_digit_string, cost: Devise.stretches),
      multi_factor_email_code_sent_at: DateTime.current
    )
    UserMailer.multi_factor_email(self, six_digit_string).deliver_now
    six_digit_string
  end

  ##
  # Validates a provided OTP code against the stored encrypted code.
  #
  # Uses BCrypt for constant-time comparison to prevent timing attacks.
  #
  # @param otp_attempt [String] the OTP code to validate
  # @return [Boolean] true if the code matches, false otherwise
  # @example
  #   user.validate_multi_factor_email_code("123456")
  #   # => true
  def validate_multi_factor_email_code(otp_attempt)
    return false if multi_factor_email_code.blank?

    db_pass = BCrypt::Password.new(multi_factor_email_code)
    db_pass == otp_attempt
  end

  ##
  # Checks whether the OTP code has expired.
  #
  # OTP codes expire 10 minutes after they are sent.
  #
  # @return [Boolean] true if expired or not yet sent, false if still valid
  # @example
  #   user.multi_factor_email_code_expired?
  #   # => false
  def multi_factor_email_code_expired?
    return true if multi_factor_email_code_sent_at.blank?

    delay = DateTime.current.to_i - multi_factor_email_code_sent_at.to_i
    delay > 10.minutes.to_i
  end

  # TOTP authentication methods

  ##
  # Generates and stores a new TOTP secret for the user.
  #
  # @return [String] the base32-encoded secret
  def generate_totp_secret
    secret = ROTP::Base32.random
    update!(otp_secret: secret)
    secret
  end

  ##
  # Returns the TOTP provisioning URI for QR code generation.
  #
  # @param issuer [String] the application name (default: "IMPACTOSS")
  # @return [String] the provisioning URI
  def totp_provisioning_uri(issuer: "IMPACTOSS")
    return nil unless otp_secret.present?

    ROTP::TOTP.new(otp_secret, issuer: issuer).provisioning_uri(email)
  end

  ##
  # Validates a TOTP code.
  #
  # @param code [String] the 6-digit TOTP code
  # @param drift [Integer] acceptable time drift in seconds (default: 30)
  # @return [Boolean] true if valid, false otherwise
  def validate_totp_code(code)
    return false unless otp_secret.present?
    return false if code.blank?

    totp = ROTP::TOTP.new(otp_secret)
    # Allow 30 seconds of drift in either direction
    totp.verify(code, drift_behind: 30, drift_ahead: 30).present?
  end

  ##
  # Checks if TOTP is enabled for this user.
  #
  # @return [Boolean] true if TOTP is enabled
  def totp_enabled?
    otp_secret.present? && otp_required_for_login
  end

  ##
  # Determines the user's MFA method.
  #
  # @return [Symbol] :totp, :email_otp, or :none
  def mfa_method
    return :totp if totp_enabled?
    return :email_otp if email_otp_enabled?
    :none
  end

  ##
  # Checks if email OTP is enabled (globally).
  #
  # @return [Boolean] true if email OTP is enabled
  def email_otp_enabled?
    Rails.application.config.mfa_methods.include?(:email_otp) &&
      Rails.application.config.require_mfa
  end

  ##
  # Checks if MFA is locked due to failed attempts.
  #
  # @return [Boolean] true if locked
  def mfa_locked?
    mfa_locked_until.present? && mfa_locked_until > Time.current
  end

  ##
  # Increments failed MFA attempts and locks if threshold exceeded.
  #
  # @param max_attempts [Integer] maximum attempts before locking (default: 5)
  def increment_mfa_failed_attempts!(max_attempts: 5)
    increment!(:mfa_failed_attempts)

    if mfa_failed_attempts >= max_attempts
      update!(mfa_locked_until: 30.minutes.from_now)
    end
  end

  ##
  # Resets MFA failed attempts counter.
  def reset_mfa_failed_attempts!
    update!(mfa_failed_attempts: 0, mfa_locked_until: nil)
  end

  private

  # Set timestamp when password changes
  def set_password_changed_at
    self.password_changed_at = Time.current
  end
end
