class AddCurrentGameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :current_game,
                  foreign_key: { to_table: :games, on_delete: :nullify },
                  null: true
  end
end
