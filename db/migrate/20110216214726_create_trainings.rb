class CreateTrainings < ActiveRecord::Migration
  def self.up
    create_table :trainings, :force => true do |t|
      t.integer :stage, :default => 0
      t.integer :zooniverse_user_id
      t.timestamps
    end
    
    add_index :trainings, :zooniverse_user_id
  end
  
  def self.down
    remove_index :trainings, :zooniverse_user_id
    drop_table :trainings
  end
end