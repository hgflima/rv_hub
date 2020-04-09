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

end

