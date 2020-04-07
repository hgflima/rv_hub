class ApplicationService

  def initialize(model)
    @model = model
  end

  def create(idempotency_key)

    return [:validation_error, @model.errors] if !@model.valid?

    @cache        = CacheClient.new('idempotency_key')
    class_name    = @model.class.name.downcase
    cached_model  = @cache.get("#{class_name}:#{idempotency_key}")

    return [:loaded, JSON.parse(cached_model)] if cached_model != nil

    @model.save
    @cache.set("#{class_name}:#{idempotency_key}", @model.attributes.to_json)
    return [:created, @model]

  end

end
