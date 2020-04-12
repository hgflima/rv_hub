class ApplicationPresenter

  def initialize(object = nil, code = nil)
    @object  = object
    @code   = code
  end

  def as_json
    body = valid? ? success : error
    return { json: body, status: get_http_status }
  end

  def as_json_collection(pagination_info)

    headers = {
      "X-Total-Items" => pagination_info[:total_items].to_s,
      "X-Total-Pages" => pagination_info[:total_pages].to_s
    }

    body              = @object.map { |m| success(m) }
    rendered_response = { json: body, status: get_http_status }

    [rendered_response, headers]

  end

  # who extends this class must implements 'success' method
  def success(object = nil)
    {
      'code': 'not_implemented'
    }
  end

  def error
    error           = {}
    error[:status]  = get_http_status
    error[:code]    = get_error_code
    error[:message] = get_error_message
    error[:errors]  = @object.errors.messages if !(@object.nil? or @object.errors.blank?)
    error[:see]     = get_error_link
    error
  end

  def get_http_status
    HTTP_STATUSES[@code]
  end

  def get_error_code
    ERROR_CODES[@code]
  end

  def get_error_message
    ERROR_MESSAGES[@code]
  end

  def get_error_link
    ERROR_LINKS[@code]
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

  ERROR_CODES = {
    :validation_error             => :validation_error,
    :item_not_found               => :item_not_found_error,
    :transition_not_accepted      => :transition_not_accepted_error,
    :idempotency_key_not_present  => :idempotency_key_error
  }

  ERROR_MESSAGES = {
    :validation_error             => "One or more fields are required and / or in an invalid format",
    :item_not_found               => "The requested item was not found",
    :transition_not_accepted      => "The requested transition of status is not accepted",
    :idempotency_key_not_present  => "The custom header field X-Idempotency-Key is required"
  }

  ERROR_LINKS = {
    :validation_error             => "https://docs.rvhub.com.br/errors#validation_error",
    :item_not_found               => "https://docs.rvhub.com.br/errors#item_not_found_error",
    :transition_not_accepted      => "https://docs.rvhub.com.br/errors#transition_not_accepted_error",
    :idempotency_key_not_present  => "https://docs.rvhub.com.br/errors#idempotency_key_not_present_error"
  }

end
