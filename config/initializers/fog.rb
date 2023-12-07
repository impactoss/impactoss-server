if ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"] && ENV["AWS_BUCKET_REGION"]
  ::FogStorage = Fog::Storage.new(
    provider: 'AWS',
    aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region: ENV['AWS_BUCKET_REGION']
  )
else
  warn "[config/initializers/fog.rb] Missing AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_BUCKET_REGION environment variables."
end
