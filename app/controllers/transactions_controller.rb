class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :delete, :capture]

  # POST /transactions/:transaction_id/capture
  def capture
    service           = TransactionService.new()
    transaction, code = service.capture(params[:transaction_id])
    presenter         = TransactionPresenter.new(transaction, code)
    render presenter.as_json
  end

  # GET /transactions
  def index
    service             = TransactionService.new()
    transactions, code  = service.find_all
    presenter           = TransactionPresenter.new(transactions, code)
    render presenter.as_json_collection
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
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find_by_uuid(params[:transaction_id])
    end

    # Only allow a trusted parameter "white list" through.
    def transaction_params
      params.permit(:carrier, :area_code, :cell_phone_number, :amount)
    end

end
