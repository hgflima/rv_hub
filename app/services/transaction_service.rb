class TransactionService < ApplicationService

  def authorize(idempotency_key)

    return [@model, :validation_error] if !@model.valid?

    @cache        = CacheClient.new('idempotency_key')
    class_name    = @model.class.name.downcase
    cached_model  = @cache.get("#{class_name}:#{idempotency_key}")

    return [Transaction.new(JSON.parse(cached_model)), :loaded] if cached_model != nil

    @model.authorize!
    @cache.set("#{class_name}:#{idempotency_key}", @model.attributes.to_json)
    return [@model, :created]

  end

  def capture(uuid)
    @model = Transaction.find_by_uuid(uuid)
    return [nil, :item_not_found] if @model == nil
    return [@model, :loaded] if (@model.status == 'captured')
    return [@model, :transition_not_accepted] if (@model.status != 'authorized')
    return [@model, :ok] if @model.capture!
  end

  def refund(uuid)
    @model = Transaction.find_by_uuid(uuid)
    return [nil, :item_not_found] if @model == nil
    return [@model, :loaded] if (@model.status == 'refunded')
    return [@model, :transition_not_accepted] if (@model.status != 'authorized')
    return [@model, :ok] if @model.refund!
  end

  def find(uuid)
    @model = Transaction.find_by_uuid(uuid)
    return [nil, :item_not_found] if @model == nil
    return [@model, :ok]
  end

  def find_all
    [Transaction.all, :ok]
  end
end
