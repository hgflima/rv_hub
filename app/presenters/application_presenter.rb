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
    {
      'code': @code,
      'errors': (@object.nil? or @object.errors.nil?) ? nil : @object.errors.messages
    }
  end

  def get_http_status
    STATUSES[@code]
  end

  def valid?
    !@object.nil? and @object.valid? and (get_http_status < 300)
  end

  STATUSES = {
    :validation_error => 422,
    :created => 201,
    :loaded => 200,
    :ok => 200,
    :item_not_found => 404,
    :transition_not_accepted => 422
  }

end
