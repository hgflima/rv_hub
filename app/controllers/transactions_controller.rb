class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :delete, :capture]

  # POST /transactions/:uuid/capture
  def capture
    @transaction.capture!
    presenter = TransactionPresenter.new(@transaction)
    render json: presenter.success
  end

  # GET /transactions
  def index
    @transactions = Transaction.all
    render json: @transactions.map { |tx| TransactionPresenter.new(tx).success }
  end

  # GET /transactions/:uuid
  def show
    presenter = TransactionPresenter.new(@transaction)
    render json: presenter.success
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.authorize!
      presenter = TransactionPresenter.new(@transaction)
      render json: presenter.success, status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  # DELETE /transactions/:uuid
  def delete
    @transaction.refund!
    presenter = TransactionPresenter.new(@transaction)
    render json: presenter.success
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
