describe TransactionPresenter do

  before(:each) do
    Transaction.destroy_all
    valid_transaction_json = payload('valid_transaction')

    for i in 1..10
      tx = Transaction.new(valid_transaction_json)
      tx.authorize!
      tx.capture!
    end
  end

  it "returns Link header field (RFC 5988) with correct first, next and last rel's (no prev)" do

    service                             = TransactionService.new()
    transactions, code, pagination_info = service.find_all(1, 2)

    presenter                   = TransactionPresenter.new(transactions, code)
    rendered_response, headers  = presenter.as_json_collection(pagination_info)

    base_url    = ENV['BASE_URL']
    api_version = ENV['API_VERSION']

    expected_header_link  = "<#{base_url}/#{api_version}/transactions?page=1&per_page=2>; rel='first', "
    expected_header_link += "<#{base_url}/#{api_version}/transactions?page=2&per_page=2>; rel='next', "
    expected_header_link += "<#{base_url}/#{api_version}/transactions?page=5&per_page=2>; rel='last'"

    expect(headers['Link']).to eq(expected_header_link)

  end

  it "returns Link header field (RFC 5988) with correct first, prev, next and last rel's" do

    service                             = TransactionService.new()
    transactions, code, pagination_info = service.find_all(2, 2)

    presenter                   = TransactionPresenter.new(transactions, code)
    rendered_response, headers  = presenter.as_json_collection(pagination_info)

    base_url    = ENV['BASE_URL']
    api_version = ENV['API_VERSION']

    expected_header_link  = "<#{base_url}/#{api_version}/transactions?page=1&per_page=2>; rel='first', "
    expected_header_link += "<#{base_url}/#{api_version}/transactions?page=1&per_page=2>; rel='prev', "
    expected_header_link += "<#{base_url}/#{api_version}/transactions?page=3&per_page=2>; rel='next', "
    expected_header_link += "<#{base_url}/#{api_version}/transactions?page=5&per_page=2>; rel='last'"

    expect(headers['Link']).to eq(expected_header_link)

  end

  it "returns Link header field (RFC 5988) with correct first, prev, and last rel's (no prev)" do

    service                             = TransactionService.new()
    transactions, code, pagination_info = service.find_all(5, 2)

    presenter                   = TransactionPresenter.new(transactions, code)
    rendered_response, headers  = presenter.as_json_collection(pagination_info)

    base_url    = ENV['BASE_URL']
    api_version = ENV['API_VERSION']

    expected_header_link  = "<#{base_url}/#{api_version}/transactions?page=1&per_page=2>; rel='first', "
    expected_header_link += "<#{base_url}/#{api_version}/transactions?page=4&per_page=2>; rel='prev', "
    expected_header_link += "<#{base_url}/#{api_version}/transactions?page=5&per_page=2>; rel='last'"

    expect(headers['Link']).to eq(expected_header_link)

  end

end
