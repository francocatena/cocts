class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :user
      t.string :password
      t.string :name
      t.string :lastname
      t.boolean :enable
      t.string :email
      t.string :salt
      t.integer :lock_version, default: 0

      t.timestamps null: false
    end

    add_index :users, :user, unique: true
  end

  def self.down
    remove_index :users, column: :user

    drop_table :users
  end
end
