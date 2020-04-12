module V1

  describe TransactionsController, type: :controller do

    before(:each) do
      @valid_transaction = Transaction.new(payload('valid_transaction'))
    end

    after(:all) do
      Transaction.destroy_all
    end

    it "returns correct transaction using uuid as unique identifier" do
      @valid_transaction.authorize!
      get '/v1/transactions/:transaction_id', transaction_id: @valid_transaction.uuid
      expect(response.status).to eq 200
    end

    it "returns 404 when call get /transactions/:transaction_id with an inexistent uuid" do
      get '/v1/transactions/:transaction_id', transaction: 'meu-ovo-uuid'
      expect(response.status).to eq 404
    end

    it "returns uuid value in the id attribute" do
      @valid_transaction.authorize!

      get '/v1/transactions/:transaction_id', transaction_id: @valid_transaction.uuid
      expect(response.status).to eq 200

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['id']).to eq @valid_transaction.uuid

    end

    it "creates a transaction correctly" do
      payload = payload('posts_valid_transaction')
      payload["headers"]["IDEMPOTENCY-KEY"] = UUID.new.generate

      controller = V1::TransactionsController.new(payload, {}, {})

      responseController = controller.process!
      response = Rack::Response.new(responseController["body"], responseController["statusCode"])

      expect(response.status).to eq 201

      parsed_response = JSON.parse(response.body[0])
      expect(parsed_response['id']).to_not be_empty

    end

    it "load transaction by the idempotency key" do

      payload = payload('posts_valid_transaction')
      payload["headers"]["IDEMPOTENCY-KEY"] = UUID.new.generate

      controller = V1::TransactionsController.new(payload, {}, {})

      responseController = controller.process!
      response = Rack::Response.new(responseController["body"], responseController["statusCode"])

      parsed_response     = JSON.parse(response.body[0])
      uuid_first_request  = parsed_response['id']

      responseController = controller.process!
      response = Rack::Response.new(responseController["body"], responseController["statusCode"])

      parsed_response     = JSON.parse(response.body[0])
      uuid_second_request = parsed_response['id']

      expect(response.status).to eq 200
      expect(uuid_first_request).to eq(uuid_second_request)

    end

    it "capture the transaction when status = authorized" do

      @valid_transaction.authorize!

      post '/v1/transactions/:transaction_id/capture', :transaction_id => @valid_transaction.uuid
      expect(response.status).to eq 200

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq('captured')

    end

    it "returns 404 when :transaction_id is not correct" do

      post '/v1/transactions/:transaction_id/capture', :transaction_id => 'meu_ovo_uuid'
      expect(response.status).to eq 404

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['code']).to eq('item_not_found')

    end

    it "returns 200 when transaction was captured before (idempotent method)" do

      @valid_transaction.authorize!
      @valid_transaction.capture!
      post '/v1/transactions/:transaction_id/capture', :transaction_id => @valid_transaction.uuid
      expect(response.status).to eq 200

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq('captured')

    end

    it "returns status: 422 and code: transition_not_accepted when transaction was refunded before" do

      @valid_transaction.authorize!
      @valid_transaction.refund!
      post '/v1/transactions/:transaction_id/capture', :transaction_id => @valid_transaction.uuid
      expect(response.status).to eq 422

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['code']).to eq('transition_not_accepted')

    end

    it "refund the transaction when status = authorized" do

      @valid_transaction.authorize!

      delete '/v1/transactions/:transaction_id', :transaction_id => @valid_transaction.uuid
      expect(response.status).to eq 200

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq('refunded')

    end

    it "returns 404 when :transaction_id is not correct" do

      delete '/v1/transactions/:transaction_id', :transaction_id => 'meu_ovo_uuid'
      expect(response.status).to eq 404

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['code']).to eq('item_not_found')

    end

    it "returns 200 when transaction was refunded before (idempotent method)" do

      @valid_transaction.authorize!
      @valid_transaction.refund!
      delete '/v1/transactions/:transaction_id', :transaction_id => @valid_transaction.uuid
      expect(response.status).to eq 200

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq('refunded')

    end

    it "returns status: 422 and code: transition_not_accepted when transaction was captured before" do

      @valid_transaction.authorize!
      @valid_transaction.capture!
      delete '/v1/transactions/:transaction_id', :transaction_id => @valid_transaction.uuid
      expect(response.status).to eq 422

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['code']).to eq('transition_not_accepted')

    end

    it "returns correcly a collection of transactions with pagination" do

      Transaction.destroy_all
      valid_transaction_json = payload('valid_transaction')

      for i in 1..10
        tx = Transaction.new(valid_transaction_json)
        tx.authorize!
        tx.capture!
      end

      get '/v1/transactions', page: 1, per_page: 2

      parsed_response = JSON.parse(response.body)
      headers         = response.headers

      expect(response.status).to eq 200
      expect(headers["X-Total-Items"]).to eq("10")
      expect(headers["X-Total-Pages"]).to eq("5")

    end

    it "returns correcly a collection of transactions with pagination (page=nil, per_page=nil)" do

      Transaction.destroy_all
      valid_transaction_json = payload('valid_transaction')

      for i in 1..10
        tx = Transaction.new(valid_transaction_json)
        tx.authorize!
        tx.capture!
      end

      get '/v1/transactions'

      parsed_response = JSON.parse(response.body)
      headers         = response.headers

      expect(response.status).to eq 200
      expect(headers["X-Total-Items"]).to eq("10")
      expect(headers["X-Total-Pages"]).to eq("1")

    end

  end

end


