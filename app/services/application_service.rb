class ApplicationService

  def initialize(model = nil)
    @model = model
  end

  def create(idempotency_key)

    return [@model, :validation_error] if !@model.valid?

    @cache        = CacheClient.new('idempotency_key')
    class_name    = @model.class.name.downcase
    cached_model  = @cache.get("#{class_name}:#{idempotency_key}")

    return [JSON.parse(cached_model), :loaded] if cached_model != nil

    @model.save
    @cache.set("#{class_name}:#{idempotency_key}", @model.attributes.to_json)
    return [@model, :created]

  end

end
