require 'fast_jsonapi'

module FastApplicationSerializer
  def self.included(base)
    base.include FastJsonapi::ObjectSerializer

    base.attribute :created_at do |object|
      object.created_at.in_time_zone.iso8601 if object.created_at
    end

    base.attribute :updated_at do |object|
      object.updated_at.in_time_zone.iso8601 if object.created_at
    end
  end
end
