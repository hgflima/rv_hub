describe Account, type: :model do

  before(:each) do
    @valid_account = Account.new(payload('valid_account'))
    @valid_account.client_id = UUID.new.generate
  end

  after(:each) do
    @valid_account.destroy
  end

  it "Must recover the account by customer ID" do
    @valid_account.save!
    expect(Account.find_by_client_id(@valid_account.client_id)).to_not be_nil
  end

end