def serialized_record(record, serializer)
  serializer.new(record).serializable_hash[:data].as_json
end
