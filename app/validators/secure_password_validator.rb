class SecurePasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # password must include latin capital letters (A-Z)
    unless /[A-Z]/.match?(value)
      record.errors.add(attribute, "must include at least one uppercase letter")
    end

    # password must include lower case Latin letters (a-z)
    unless /[a-z]/.match?(value)
      record.errors.add(attribute, "must include at least one lowercase letter")
    end

    # password must include basic digits (0-9)
    unless /\d/.match?(value)
      record.errors.add(attribute, "must include at least one digit")
    end

    # password must include non-alphanumeric characters (like !, $, #, -, &)
    unless /[^A-Za-z0-9]/.match?(value)
      record.errors.add(attribute, "must include at least one special character")
    end

    # password must not contain the whole or parts of the login name (uid/email address)
    email_to_check = record.uid.presence || record.email.presence
    if email_to_check.present? && value.present?
      # Split email into parts and filter out short segments (< 3 chars)
      email_parts = email_to_check.downcase.split(/[@.]/).select { |part| part.length >= 3 }
      password_downcased = value.downcase

      email_parts.each do |part|
        if password_downcased.include?(part)
          record.errors.add(attribute, "cannot contain your email address or parts of it")
          break
        end
      end
    end

    # password must not contain the whole or parts of the user's name
    if record.name.present? && value.present?
      name_parts = record.name.downcase.split(/\s+/).select { |part| part.length >= 3 }
      password_downcased = value.downcase

      name_parts.each do |part|
        if password_downcased.include?(part)
          record.errors.add(attribute, "cannot contain your name or parts of it")
          break
        end
      end
    end
  end
end
