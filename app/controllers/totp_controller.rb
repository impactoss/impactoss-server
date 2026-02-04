# frozen_string_literal: true

##
# Handles TOTP (Time-based One-Time Password) setup and management.
#
# This controller manages the enrollment, verification, and disabling
# of TOTP authentication for users.
class TotpController < ApplicationController
  before_action :authenticate_user!

  ##
  # Initiates TOTP setup by generating a secret and returning QR code data.
  #
  # @api POST /auth/totp/setup
  # @return [JSON] secret, QR code SVG, and provisioning URI
  # @status 200 Setup data generated
  # @status 403 TOTP not enabled in config
  #
  # @example Response
  #   {
  #     "secret": "JBSWY3DPEHPK3PXP",
  #     "qr_code": "<svg>...</svg>",
  #     "provisioning_uri": "otpauth://totp/..."
  #   }
  def setup
    unless Rails.application.config.mfa_methods.include?(:totp)
      return render json: {errors: ["TOTP is not enabled"]}, status: :forbidden
    end

    # Generate new secret (doesn't enable TOTP yet)
    secret = current_user.generate_totp_secret
    provisioning_uri = current_user.totp_provisioning_uri

    # Generate QR code
    qrcode = RQRCode::QRCode.new(provisioning_uri)
    svg = qrcode.as_svg(
      module_size: 4,
      standalone: true,
      use_path: true
    )

    render json: {
      secret: secret,
      qr_code: svg,
      provisioning_uri: provisioning_uri
    }
  end

  ##
  # Enables TOTP after verifying the user can generate valid codes.
  #
  # @api POST /auth/totp/enable
  # @param code [String] TOTP code from authenticator app
  # @return [JSON] success message and backup codes
  # @status 200 TOTP enabled
  # @status 400 Invalid code
  # @status 403 TOTP not enabled in config
  #
  # @example Request
  #   POST /auth/totp/enable
  #   { "code": "123456" }
  #
  # @example Response
  #   {
  #     "message": "TOTP enabled successfully",
  #     "backup_codes": ["a1b2c3d4", "e5f6g7h8", ...]
  #   }
  def enable
    unless Rails.application.config.mfa_methods.include?(:totp)
      return render json: {errors: ["TOTP is not enabled"]}, status: :forbidden
    end

    if params[:code].blank?
      return render json: {errors: ["Code is required"]}, status: :unprocessable_entity
    end

    unless current_user.otp_secret.present?
      return render json: {errors: ["Please set up TOTP first"]}, status: :unprocessable_entity
    end

    # Verify the code works before enabling
    unless current_user.validate_totp_code(params[:code])
      return render json: {errors: ["Invalid TOTP code"]}, status: :bad_request
    end

    # Enable TOTP
    current_user.update!(otp_required_for_login: true)

    # Generate backup codes
    backup_codes = BackupCode.generate_for_user(current_user)

    render json: {
      message: "TOTP enabled successfully",
      backup_codes: backup_codes
    }
  end

  ##
  # Disables TOTP for the user.
  #
  # @api POST /auth/totp/disable
  # @param password [String] user's current password (for verification)
  # @return [JSON] success message
  # @status 200 TOTP disabled
  # @status 401 Invalid password
  #
  # @example Request
  #   POST /auth/totp/disable
  #   { "password": "current_password" }
  def disable
    unless current_user.valid_password?(params[:password])
      return render json: {errors: ["Invalid password"]}, status: :unauthorized
    end

    current_user.update!(
      otp_required_for_login: false,
      otp_secret: nil
    )

    # Clear backup codes
    current_user.backup_codes.destroy_all

    render json: {message: "TOTP disabled successfully"}
  end

  ##
  # Regenerates backup codes for TOTP.
  #
  # @api POST /auth/totp/backup_codes/regenerate
  # @param password [String] user's current password (for verification)
  # @return [JSON] new backup codes
  # @status 200 Backup codes regenerated
  # @status 401 Invalid password
  # @status 403 TOTP not enabled for user
  #
  # @example Response
  #   {
  #     "backup_codes": ["a1b2c3d4", "e5f6g7h8", ...]
  #   }
  def regenerate_backup_codes
    unless current_user.totp_enabled?
      return render json: {errors: ["TOTP is not enabled for your account"]}, status: :forbidden
    end

    unless current_user.valid_password?(params[:password])
      return render json: {errors: ["Invalid password"]}, status: :unauthorized
    end

    backup_codes = BackupCode.generate_for_user(current_user)

    render json: {
      backup_codes: backup_codes,
      message: "Backup codes regenerated successfully"
    }
  end

  ##
  # Returns the count of remaining backup codes.
  #
  # @api GET /auth/totp/backup_codes/count
  # @return [JSON] count of unused backup codes
  # @status 200 Count returned
  # @status 403 TOTP not enabled for user
  def backup_codes_count
    unless current_user.totp_enabled?
      return render json: {errors: ["TOTP is not enabled for your account"]}, status: :forbidden
    end

    count = BackupCode.remaining_count(current_user)

    render json: {remaining_count: count}
  end
end
