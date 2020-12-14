require 'fast_jsonapi'

module FastApplicationSerializer
  def self.included(base)
    base.include FastJsonapi::ObjectSerializer

    base.attribute :created_at do |object|
      object.created_at.in_time_zone.iso8601 if object.created_at
    end

    base.attribute :updated_at do |object|
      # FIXME: this look like there's a bug... should be `if object.updated_at` ?
            # I mean, there should always be both but still.
      object.updated_at.in_time_zone.iso8601 if object.created_at
    end
  end
end
