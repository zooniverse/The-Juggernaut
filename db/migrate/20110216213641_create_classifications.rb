class CreateClassifications < ActiveRecord::Migration
  def self.up
    create_table :classifications, :force => true do |t|
      t.string :locale
      t.integer :total_score
      t.datetime :started
      t.datetime :ended
      t.integer :workflow_id
      t.integer :zooniverse_user_id
      t.timestamps
    end
    
    add_index :classifications, :zooniverse_user_id
    add_index :classifications, :workflow_id
  end
  
  def self.down
    remove_index :classifications, :workflow_id
    remove_index :classifications, :zooniverse_user_id
    drop_table :classifications
  end
end
