class PasswordsController < DeviseTokenAuth::PasswordsController
  def redirect_options
    trusted_host = URI.parse(ENV["CLIENT_URL"].to_s.strip).host
    redirect_host = begin
      URI.parse(params[:redirect_url]).host
    rescue URI::InvalidURIError, ArgumentError
      nil
    end

    allowed_hosts = [trusted_host, "localhost", "127.0.0.1"]

    if allowed_hosts.include?(redirect_host)
      {allow_other_host: true}
    else
      raise ActionController::BadRequest.new("Unsafe redirect_url: #{params[:redirect_url]}")
    end
  end
end
