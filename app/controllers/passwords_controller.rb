class PasswordsController < DeviseTokenAuth::PasswordsController
  def redirect_options
    trusted_host = URI.parse(ENV["CLIENT_URL"].to_s.strip).host
    redirect_host = begin
      URI.parse(params[:redirect_url]).host
    rescue
      nil
    end

    allowed_hosts = [trusted_host, "localhost", "127.0.0.1"]

    if allowed_hosts.include?(redirect_host)
      {allow_other_host: true}
    else
      raise ActionController::BadRequest.new("Unsafe redirect_url: #{params[:redirect_url]}")
    end
  end

  def update
    @resource ||= set_user_by_token
    unless @resource&.allow_password_change &&
        @resource.reset_password_sent_at.present? &&
        @resource.reset_password_sent_at > Devise.reset_password_within.ago
      return render json: {success: false, errors: ["Password change not permitted or expired."]}, status: :forbidden
    end
    super
  end

  # Stock DTA raises ActionController::RoutingError on an invalid or expired
  # reset token, which surfaces as a 500 in this API-only app. Redirect the
  # browser to the client's link-expired page instead, so a dead link lands on a
  # real page rather than an error.
  def render_edit_error
    redirect_to(
      File.join(ENV.fetch("CLIENT_URL"), ENV.fetch("CLIENT_RESET_LINK_INVALID_PATH", "not-found")),
      allow_other_host: true
    )
  end
end
