describe Transaction, type: :model do

  before(:each) do
    @valid_transaction = Transaction.new(payload('valid_transaction'))
  end

  it "is not valid without a valid carrier" do
    @valid_transaction.carrier = nil
    expect(@valid_transaction).to_not be_valid
  end

  it "is not valid without a valid area_code" do
    @valid_transaction.area_code = nil
    expect(@valid_transaction).to_not be_valid
  end

  it "is not valid without a valid cell_phone_number" do
    @valid_transaction.cell_phone_number = nil
    expect(@valid_transaction).to_not be_valid
  end

  it "is not valid without a valid amount" do
    @valid_transaction.amount = nil
    expect(@valid_transaction).to_not be_valid
  end

  it "is not valid when the amount field type is different than an integer" do
    @valid_transaction.amount = "meu ovo"
    expect(@valid_transaction).to_not be_valid
  end

  it "is not valid when the amount is equal or less than 0" do
    @valid_transaction.amount = 0
    expect(@valid_transaction).to_not be_valid
  end

  it "generate an UUID when create then instance of Transaction" do
    @valid_transaction.save!
    expect(UUID.validate(@valid_transaction.uuid)).to_not be_nil
    @valid_transaction.destroy
  end

  it "will authorize transaction when amount <= 10000" do
    @valid_transaction.authorize!
    expect(@valid_transaction.status).to eq('authorized')
    expect(@valid_transaction.uuid).to_not be_empty
    @valid_transaction.destroy
  end

  it "will deny transaction when amount > 10000" do
    @valid_transaction.amount = 30000
    @valid_transaction.authorize!
    expect(@valid_transaction.status).to eq('denied')
    expect(@valid_transaction.uuid).to_not be_empty
    @valid_transaction.destroy
  end

  it "will capture the transaction" do
    @valid_transaction.authorize!
    @valid_transaction.capture!
    expect(@valid_transaction.status).to eq('captured')
    expect(@valid_transaction.uuid).to_not be_empty
    @valid_transaction.destroy
  end

  it "will not capture the transaction" do
    captured = @valid_transaction.capture!
    expect(captured).to be_falsey
    @valid_transaction.destroy
  end

  it "will refund the transaction" do
    @valid_transaction.authorize!
    @valid_transaction.refund!
    expect(@valid_transaction.status).to eq('refunded')
    expect(@valid_transaction.uuid).to_not be_empty
  end

  it "will not refund the transaction" do
    refunded = @valid_transaction.refund!
    expect(refunded).to be_falsey
  end

  it "will create a status_history when status change to authorized" do
    @valid_transaction.authorize!
    expect(@valid_transaction.status_history.first.status).to eq('authorized')
    @valid_transaction.destroy
  end

  it "will create a status_history when status change to denied" do
    @valid_transaction.amount = 30000
    @valid_transaction.authorize!
    expect(@valid_transaction.status_history.first.status).to eq('denied')
    @valid_transaction.destroy
  end

  it "will create a status_history when status change to captured" do
    @valid_transaction.authorize!
    @valid_transaction.capture!
    expect(@valid_transaction.status_history.first.status).to eq('authorized')
    expect(@valid_transaction.status_history.last.status).to eq('captured')
    @valid_transaction.destroy
  end

  it "will create a status_history when status change to refunded" do
    @valid_transaction.authorize!
    @valid_transaction.refund!
    expect(@valid_transaction.status_history.first.status).to eq('authorized')
    expect(@valid_transaction.status_history.last.status).to eq('refunded')
    @valid_transaction.destroy
  end

end
