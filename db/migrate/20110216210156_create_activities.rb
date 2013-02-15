class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities, :force => true do |t|
      t.float :score
      t.integer :counter, :default => 0
      t.integer :zooniverse_user_id
      t.integer :workflow_id
      t.timestamps
    end
    
    add_index :activities, :workflow_id
    add_index :activities, :zooniverse_user_id
  end
  
  def self.down
    remove_index :activities, :zooniverse_user_id
    remove_index :activities, :workflow_id
    drop_table :activities
  end
end
