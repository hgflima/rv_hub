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

  protected
    def offset(page, per_page)
      (page - 1) * per_page
    end

    def total_pages(total_items, per_page)
      (total_items * 1.0 / per_page).ceil.to_i
    end

end
