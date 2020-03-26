class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :carrier
      t.string :area_code
      t.string :cell_phone_number
      t.integer :amount
      t.string :status

      t.timestamps
    end
  end
end
