class RenameEmailAddressToUsernameOnUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :email_address, :username
  end
end
