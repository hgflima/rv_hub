describe TransactionsController, type: :controller do

  before(:each) do
    @valid_transaction = Transaction.new(payload('valid_transaction'))
  end

  after(:all) do
    Transaction.destroy_all
  end

  it "returns correct transaction using uuid as unique identifier" do
    @valid_transaction.authorize!
    get '/transactions/:transaction_id', transaction_id: @valid_transaction.uuid
    expect(response.status).to eq 200
  end

  it "returns 404 when call get /transactions/:transaction_id with an inexistent uuid" do
    get '/transactions/:transaction_id', transaction: 'meu-ovo-uuid'
    expect(response.status).to eq 404
  end

  it "returns uuid value in the id attribute" do
    @valid_transaction.authorize!

    get '/transactions/:transaction_id', transaction_id: @valid_transaction.uuid
    expect(response.status).to eq 200

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['id']).to eq @valid_transaction.uuid

  end

  it "creates a transaction correctly" do

    request.headers['IDEMPOTENCY-KEY'] = UUID.new.generate
    post '/transactions', { :carrier => "vivo",
                            :area_code => "11",
                            :cell_phone_number => "994145350",
                            :amount => 1000 }

    expect(response.status).to eq 201

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['id']).to_not be_empty

  end

  it "load transaction by the idempotency key" do

    request.headers['IDEMPOTENCY-KEY'] = UUID.new.generate
    json_request = { :carrier => "vivo",
                     :area_code => "11",
                     :cell_phone_number => "994145350",
                     :amount => 1000 }

    post '/transactions', json_request

    parsed_response     = JSON.parse(response.body)
    uuid_first_request  = parsed_response['id']

    post '/transactions', json_request

    parsed_response     = JSON.parse(response.body)
    uuid_second_request = parsed_response['id']

    expect(response.status).to eq 200
    expect(uuid_first_request).to eq(uuid_second_request)

  end

  it "capture the transaction when status = authorized" do

    @valid_transaction.authorize!

    post '/transactions/:transaction_id/capture', :transaction_id => @valid_transaction.uuid
    expect(response.status).to eq 200

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['status']).to eq('captured')

  end

  it "returns 404 when :transaction_id is not correct" do

    post '/transactions/:transaction_id/capture', :transaction_id => 'meu_ovo_uuid'
    expect(response.status).to eq 404

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['code']).to eq('item_not_found')

  end

  it "returns 200 when transaction was captured before (idempotent method)" do

    @valid_transaction.authorize!
    @valid_transaction.capture!
    post '/transactions/:transaction_id/capture', :transaction_id => @valid_transaction.uuid
    expect(response.status).to eq 200

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['status']).to eq('captured')

  end

  it "returns status: 422 and code: transition_not_accepted when transaction was refunded before" do

    @valid_transaction.authorize!
    @valid_transaction.refund!
    post '/transactions/:transaction_id/capture', :transaction_id => @valid_transaction.uuid
    expect(response.status).to eq 422

    parsed_response = JSON.parse(response.body)
    pp parsed_response

    expect(parsed_response['code']).to eq('transition_not_accepted')

  end

  it "refund the transaction when status = authorized" do

    @valid_transaction.authorize!

    delete '/transactions/:transaction_id', :transaction_id => @valid_transaction.uuid
    expect(response.status).to eq 200

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['status']).to eq('refunded')

  end

  it "returns 404 when :transaction_id is not correct" do

    delete '/transactions/:transaction_id', :transaction_id => 'meu_ovo_uuid'
    expect(response.status).to eq 404

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['code']).to eq('item_not_found')

  end

  it "returns 200 when transaction was refunded before (idempotent method)" do

    @valid_transaction.authorize!
    @valid_transaction.refund!
    delete '/transactions/:transaction_id', :transaction_id => @valid_transaction.uuid
    expect(response.status).to eq 200

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['status']).to eq('refunded')

  end

  it "returns status: 422 and code: transition_not_accepted when transaction was captured before" do

    @valid_transaction.authorize!
    @valid_transaction.capture!
    delete '/transactions/:transaction_id', :transaction_id => @valid_transaction.uuid
    expect(response.status).to eq 422

    parsed_response = JSON.parse(response.body)
    expect(parsed_response['code']).to eq('transition_not_accepted')

  end

  it "returns correcly a collection of transactions" do

    Transaction.destroy_all

    tx1 = @valid_transaction
    tx2 = Transaction.new(@valid_transaction.attributes)

    tx1.authorize!
    tx1.capture!

    tx2.authorize!
    tx2.refund!

    get '/transactions'
    expect(response.status).to eq 200

    parsed_response = JSON.parse(response.body)

    expect(parsed_response.first['status']).to eq('captured')
    expect(parsed_response.last['status']).to eq('refunded')

  end

end
