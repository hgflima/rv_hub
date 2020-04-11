describe TransactionService do

  before(:each) do
    @valid_transaction = Transaction.new(payload('valid_transaction'))
  end

  after(:all) do
    Transaction.destroy_all
  end

  it "returns created when authorize is called" do

    idempotency_key = UUID.new.generate
    service         = TransactionService.new(@valid_transaction)
    transaction, code = service.authorize(idempotency_key)
    expect(code).to eq(:created)
    expect(transaction.status).to eq('authorized')

  end

  it "returns loaded when authorize is called" do

    idempotency_key = UUID.new.generate
    service         = TransactionService.new(@valid_transaction)
    transaction, code = service.authorize(idempotency_key)

    # again
    transaction, code = service.authorize(idempotency_key)

    expect(code).to eq(:loaded)
    expect(transaction.status).to eq('authorized')

  end

  it "returns idempotency_key_not_present when authorize is called" do
    service           = TransactionService.new(@valid_transaction)
    transaction, code = service.authorize(nil)
    expect(code).to eq(:idempotency_key_not_present)
  end

  it "returns validation_error when authorize is called" do

    @valid_transaction.amount = 0

    idempotency_key = UUID.new.generate
    service         = TransactionService.new(@valid_transaction)
    transaction, code = service.authorize(idempotency_key)

    expect(code).to eq(:validation_error)

  end

  it "returns item_not_found when capture is called" do

    service           = TransactionService.new(nil)
    transaction, code = service.capture("qqr-uuid")

    expect(code).to eq(:item_not_found)

  end

  it "returns transition_not_accepted when capture is called" do

    @valid_transaction.authorize!
    @valid_transaction.refund!

    service           = TransactionService.new(nil)
    transaction, code = service.capture(@valid_transaction.uuid)

    expect(code).to eq(:transition_not_accepted)

  end

  it "returns loaded when capture is called" do

    @valid_transaction.authorize!
    @valid_transaction.capture!

    service           = TransactionService.new(nil)
    transaction, code = service.capture(@valid_transaction.uuid)

    expect(code).to eq(:loaded)

  end

  it "returns ok when capture is called" do

    @valid_transaction.authorize!

    service           = TransactionService.new(nil)
    transaction, code = service.capture(@valid_transaction.uuid)

    expect(code).to eq(:ok)

  end

  it "returns item_not_found when refund is called" do

    service           = TransactionService.new(nil)
    transaction, code = service.refund("qqr-uuid")

    expect(code).to eq(:item_not_found)

  end

  it "returns transition_not_accepted when refund is called" do

    @valid_transaction.authorize!
    @valid_transaction.capture!

    service           = TransactionService.new(nil)
    transaction, code = service.refund(@valid_transaction.uuid)

    expect(code).to eq(:transition_not_accepted)

  end

  it "returns loaded when refund is called" do

    @valid_transaction.authorize!
    @valid_transaction.refund!

    service           = TransactionService.new(nil)
    transaction, code = service.refund(@valid_transaction.uuid)

    expect(code).to eq(:loaded)

  end

  it "returns ok when refund is called" do

    @valid_transaction.authorize!

    service           = TransactionService.new(nil)
    transaction, code = service.refund(@valid_transaction.uuid)

    expect(code).to eq(:ok)

  end

  it "returns code: item_not_found and transaction: nil when find is called" do
    service           = TransactionService.new(nil)
    transaction, code = service.find("meu-ovo-uuid")
    expect(code).to eq(:item_not_found)
  end

  it "returns correctly code and transaction when find is called" do
    @valid_transaction.authorize!
    service = TransactionService.new(nil)
    transaction, code = service.find(@valid_transaction.uuid)
    expect(code).to eq(:ok)
    expect(transaction.status).to eq("authorized")
  end

  it "returns correctly a collection of transactions" do

    # gambola?
    Transaction.destroy_all

    tx1 = @valid_transaction
    tx2 = Transaction.new(@valid_transaction.attributes)

    tx1.authorize!
    tx1.capture!

    tx2.authorize!
    tx2.refund!

    service = TransactionService.new(nil)
    transactions, code = service.find_all

    expect(code).to eq(:ok)
    expect(transactions.size).to eq(2)
    expect(transactions.first.status).to eq('captured')
    expect(transactions.last.status).to eq('refunded')

  end

end
