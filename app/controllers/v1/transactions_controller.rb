module V1

  class TransactionsController < ApplicationController
    
    #authorizer "main#RvHubCognito"
    #before_action :set_account, only: [:create]
    before_action :set_pagination_params, only: [:index]

    # POST /transactions/:transaction_id/capture
    def capture
      service           = TransactionService.new()
      transaction, code = service.capture(params[:transaction_id])
      presenter         = TransactionPresenter.new(transaction, code)
      render presenter.as_json
    end

    # GET /transactions
    def index
      
      service                               = TransactionService.new()
      transactions, code, pagination_info   = service.find_all(@page, @per_page)
      presenter                             = TransactionPresenter.new(transactions, code)
      rendered_response, headers            = presenter.as_json_collection(pagination_info)

      set_headers(headers)
      render rendered_response

    end

    # GET /transactions/:transaction_id
    def show
      service           = TransactionService.new()
      transaction, code = service.find(params[:transaction_id])
      presenter         = TransactionPresenter.new(transaction, code)
      render presenter.as_json
    end

    # POST /transactions
    def create

      transaction       = Transaction.new(transaction_params)
      idempotency_key   = headers['idempotency-key']

      service           = TransactionService.new(transaction)
      transaction, code = service.authorize(idempotency_key)

      presenter         = TransactionPresenter.new(transaction, code)
      render presenter.as_json

    end

    # DELETE /transactions/:transaction_id
    def delete
      service           = TransactionService.new()
      transaction, code = service.refund(params[:transaction_id])
      presenter         = TransactionPresenter.new(transaction, code)
      render presenter.as_json
    end

    private

      # Only allow a trusted parameter "white list" through.
      def transaction_params
        params.permit(:carrier, :area_code, :cell_phone_number, :amount)
      end

  end

end


