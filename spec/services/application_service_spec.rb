describe ApplicationService do

  before(:each) do
    @valid_transaction = Transaction.new(payload('valid_transaction'))
  end

  it "returned created when idempotency-key dont exists" do
    service = ApplicationService.new(@valid_transaction)
    transaction, code = service.create(UUID.new.generate)
    expect(code).to eq(:created)
    @valid_transaction.destroy
  end

  it "returned loaded when idempotency-key exists" do

    idempotency_key = UUID.new.generate
    service = ApplicationService.new(@valid_transaction)
    transaction, code = service.create(idempotency_key)

    # one more time to get cached version
    transaction, code = service.create(idempotency_key)
    expect(code).to eq(:loaded)

  end

  it "returned validation_error when model is not valid" do
    @valid_transaction.amount = 0
    service = ApplicationService.new(@valid_transaction)
    transaction, code = service.create(@valid_transaction)
    expect(code).to eq(:validation_error)
  end

end
