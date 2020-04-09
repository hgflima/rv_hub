class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :client_id
      t.string :login
      t.string :password
      t.string :store

      t.timestamps
    end
  end
end
