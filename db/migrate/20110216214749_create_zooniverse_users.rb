class CreateZooniverseUsers < ActiveRecord::Migration
  def self.up
    create_table :zooniverse_users, :force => true do |t|
      t.integer :zooniverse_user_id
      t.string :api_key
      t.string :name
      t.boolean :admin, :default => false
      t.timestamps
    end
    
    add_index :zooniverse_users, :zooniverse_user_id
  end
  
  def self.down
    remove_index :zooniverse_users, :zooniverse_user_id
    drop_table :zooniverse_users
  end
end
