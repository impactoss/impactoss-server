class S3Controller < ApplicationController
  after_action :verify_authorized, except: :sign

  def sign
    options = {path_style: true}
    headers = {
      "Content-Type" => params[:contentType],
      "x-amz-acl" => "public-read"
    }

    object_path = "#{ENV["S3_ASSET_FOLDER"]}/#{params[:objectName]}"
    url = ::FogStorage.put_object_url(ENV["S3_BUCKET_NAME"], object_path, 15.minutes.from_now.to_time.to_i, headers, options)

    render json: {
      signedUrl: "#{ENV["CLIENT_URL"]}/#{object_path}?#{URI(url).query}"
    }
  end
end
