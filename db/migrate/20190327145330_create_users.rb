class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :login
      t.text :info
      t.text :raw_info

      t.timestamps
    end

    add_index :users, :login
    add_index :users, [:provider, :uid]
  end
end
