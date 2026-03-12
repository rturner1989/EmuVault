class AddApiTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :api_token, :string
    add_index :users, :api_token, unique: true
    User.find_each { |u| u.update_column(:api_token, SecureRandom.hex(32)) }
  end
end
