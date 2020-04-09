describe ApplicationPresenter do

  before(:each) do
    @valid_transaction = Transaction.new(payload('valid_transaction'))
  end

  it "returns an error json" do

    @valid_transaction.amount = 0

    service           = ApplicationService.new(@valid_transaction)
    transaction, code = service.create(UUID.new.generate)

    presenter   = ApplicationPresenter.new(transaction, code)
    error_json  = presenter.as_json

    expect(error_json[:status]).to eq(422)
    expect(error_json[:json][:code]).to eq(:validation_error)

  end

  it "returns code: item_not_found, status: 404" do

    transaction, code = [nil, :item_not_found]

    presenter = ApplicationPresenter.new(transaction, code)
    error_json = presenter.as_json

    expect(error_json[:status]).to eq(404)
    expect(error_json[:json][:code]).to eq(:item_not_found)

  end

  it "returns code: transition_not_accepted, status: 422" do

    @valid_transaction.authorize!
    @valid_transaction.capture!

    transaction, code = [@valid_transaction, :transition_not_accepted]

    presenter = ApplicationPresenter.new(transaction, code)
    error_json = presenter.as_json

    expect(error_json[:status]).to eq(422)
    expect(error_json[:json][:code]).to eq(:transition_not_accepted)

  end

end

