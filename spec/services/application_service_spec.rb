describe ApplicationService do

  before(:each) do
    @valid_transaction = Transaction.new(payload('valid_transaction'))
  end

  it "returned created when idempotency-key dont exists" do
    service = ApplicationService.new(@valid_transaction)
    status, returned_model = service.create(UUID.new.generate)
    expect(status).to eq(:created)
    @valid_transaction.destroy
  end

  it "returned loaded when idempotency-key exists" do

    idempotency_key = UUID.new.generate
    service = ApplicationService.new(@valid_transaction)
    status, returned_model = service.create(idempotency_key)

    # one more time to get cached version
    status, returned_model = service.create(idempotency_key)
    expect(status).to eq(:loaded)

  end

  it "returned validation_error when model is not valid" do

    @valid_transaction.amount = 0
    service = ApplicationService.new(@valid_transaction)
    status, returned_model = service.create(@valid_transaction)
    expect(status).to eq(:validation_error)
    @valid_transaction.destroy

  end

end
