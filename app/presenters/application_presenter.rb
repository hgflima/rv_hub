class ApplicationPresenter

  def initialize(object = nil, code = nil)
    @object  = object
    @code   = code
  end

  def as_json
    body = valid? ? success : error
    return { json: body, status: get_http_status }
  end

  def as_json_collection
    body = @object.map { |m| success(m) }
    return { json: body, status: get_http_status } 
  end

  # who extends this class must implements 'success' method
  def success(object = nil)
    {
      'code': 'not_implemented'
    }
  end

  def error
    error           = {}
    error[:code]    = @code
    error[:errors]  = @object.errors.messages if !(@object.nil? or @object.errors.blank?)
    error
  end

  def get_http_status
    HTTP_STATUSES[@code]
  end

  # O presenter deve considerar valido os objetos que:
  # 1. Não forem nil
  # 2. Model valido (nenhum erro de validação)
  # 3. O http status code for da familia 2xx
  def valid?
    !@object.nil? and @object.valid? and (get_http_status < 300)
  end

  HTTP_STATUSES = {
    :validation_error             => 400,
    :created                      => 201,
    :loaded                       => 200,
    :ok                           => 200,
    :item_not_found               => 404,
    :transition_not_accepted      => 422,
    :idempotency_key_not_present  => 422
  }

end
