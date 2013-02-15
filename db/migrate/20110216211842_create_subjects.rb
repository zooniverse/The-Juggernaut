class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects, :force => true do |t|
      t.string :name
      t.string :location
      t.string :thumbnail_location
      t.integer :classification_count, :default => 0
      t.text :external_ref
      t.float :average_score
      t.boolean :active
      t.integer :workflow_id
      t.string :zooniverse_id
      t.timestamps
    end
    
    add_index :subjects, :active
    add_index :subjects, :classification_count
    add_index :subjects, :workflow_id
    add_index :subjects, :zooniverse_id
  end
  
  def self.down
    remove_index :subjects, :zooniverse_id
    remove_index :subjects, :workflow_id
    remove_index :subjects, :classification_count
    remove_index :subjects, :active
    drop_table :subjects
  end
end
