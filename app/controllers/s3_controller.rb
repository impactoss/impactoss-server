class S3Controller < ApplicationController
  after_action :verify_authorized, except: :sign

  def sign
    render json: {error: "Not configured"} and return unless defined?(::FogStorage)

    options = {path_style: true}
    headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}

    object_path = "#{ENV["S3_ASSET_FOLDER"]}/#{params[:objectName]}"
    s3_url = ::FogStorage.put_object_url(ENV["S3_BUCKET_NAME"], object_path, 15.minutes.from_now.to_time.to_i, headers, options)
    url = "#{ENV["CLIENT_URL"]}/#{object_path}?#{URI(s3_url).query}"

    render json: {signedUrl: url}
  end
end
