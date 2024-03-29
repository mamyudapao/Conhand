class CreateMicroposts < ActiveRecord::Migration[5.2]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user

      t.timestamps
    end
    add_index :microposts, [:user_id, :created_at]
  end
end
