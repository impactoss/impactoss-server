class S3Controller < ApplicationController
  after_action :verify_authorized, except: :sign

  def sign
    options = {path_style: true}
    headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}

    url = FogStorage.put_object_url(ENV["S3_BUCKET_NAME"], "#{ENV["S3_ASSET_FOLDER"]}/#{params[:objectName]}", 15.minutes.from_now.to_time.to_i, headers, options)
    protocol_path = url.split("//")
    path = protocol_path.last
    path_query = path.split("?")
    query = path_query[1]
    urlAlt = "#{ENV["CLIENT_URL"]}/#{ENV["S3_ASSET_FOLDER"]}/#{params[:objectName]}?#{query}"
    render json: {signedUrl: urlAlt}
  end
end
