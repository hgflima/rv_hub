class AddUuidToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :uuid, :string
  end
end
