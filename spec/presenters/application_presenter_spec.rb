describe ApplicationPresenter do

  before(:each) do
    @valid_transaction = Transaction.new(payload('valid_transaction'))
  end

  it "returns validation_error" do

    @valid_transaction.amount = 0

    service           = ApplicationService.new(@valid_transaction)
    transaction, code = service.create(UUID.new.generate)

    presenter   = ApplicationPresenter.new(transaction, code)
    error_json  = presenter.as_json

    expect(error_json[:status]).to eq(400)
    expect(error_json[:json][:code]).to eq(:validation_error)

  end

  it "returns code: item_not_found, status: 404" do

    transaction, code = [nil, :item_not_found]

    presenter = ApplicationPresenter.new(transaction, code)
    error_json = presenter.as_json

    expect(error_json[:status]).to eq(404)
    expect(error_json[:json][:code]).to eq(:item_not_found_error)

  end

  it "returns code: transition_not_accepted, status: 422" do

    @valid_transaction.authorize!
    @valid_transaction.capture!

    transaction, code = [@valid_transaction, :transition_not_accepted]

    presenter = ApplicationPresenter.new(transaction, code)
    error_json = presenter.as_json

    expect(error_json[:status]).to eq(422)
    expect(error_json[:json][:code]).to eq(:transition_not_accepted_error)

  end

  it "returns correctly pagination_info and transaction data when as_json_collection method is called" do

    Transaction.destroy_all
    valid_transaction_json = payload('valid_transaction')

    for i in 1..10
      tx = Transaction.new(valid_transaction_json)
      tx.authorize!
      tx.capture!
    end

    service                             = TransactionService.new()
    transactions, code, pagination_info = service.find_all(1, 2)

    presenter                   = ApplicationPresenter.new(transactions, code)
    rendered_response, headers  = presenter.as_json_collection(pagination_info)

    expect(rendered_response[:json].size).to eq(2)
    expect(rendered_response[:status]).to eq(200)
    expect(headers["X-Total-Items"]).to eq("10")
    expect(headers["X-Total-Pages"]).to eq("5")

  end

end

