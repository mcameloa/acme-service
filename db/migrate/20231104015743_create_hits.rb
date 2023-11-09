class CreateHits < ActiveRecord::Migration[7.1]
  def change
    create_table :hits do |t|
      t.integer :user_id
      t.string :endpoint

      t.timestamps
    end
  end
end
