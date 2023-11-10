class AddIndexToHitsUserId < ActiveRecord::Migration[7.1]
  def change
    add_index :hits, :user_id, unique: false
  end
end
