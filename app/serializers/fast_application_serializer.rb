require "jsonapi/serializer"

module FastApplicationSerializer
  def self.included(base)
    base.include JSONAPI::Serializer

    base.attribute :created_at do |object|
      object.created_at&.in_time_zone&.iso8601
    end

    base.attribute :updated_at do |object|
      object.updated_at&.in_time_zone&.iso8601
    end
  end
end
