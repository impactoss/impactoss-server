# frozen_string_literal: true

class User < VersionedRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
  #  :omniauthable
  include DeviseTokenAuth::Concerns::User

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :managed_categories, foreign_key: :manager_id, class_name: "Category"
  has_many :managed_indicators, foreign_key: :manager_id, class_name: "Indicator"
  has_many :user_categories
  has_many :categories, through: :user_categories
  has_many :bookmarks

  belongs_to :relationship_updated_by, class_name: "User", required: false

  validates :email, presence: true
  validates :name, presence: true

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
end
