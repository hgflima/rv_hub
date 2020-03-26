class CreateStatusHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :status_histories do |t|
      t.string :status
      t.references :transaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
