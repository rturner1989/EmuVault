class AddGamesViewPreferenceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :games_view_preference, :string, default: "card", null: false
  end
end
