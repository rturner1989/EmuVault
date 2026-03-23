class AddKumaUrlToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :kuma_url, :string
  end
end
