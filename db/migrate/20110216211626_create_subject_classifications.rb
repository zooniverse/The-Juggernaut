class CreateSubjectClassifications < ActiveRecord::Migration
  def self.up
    create_table :subject_classifications, :force => true do |t|
      t.integer :classification_id
      t.integer :subject_id
      t.timestamps
    end
    
    add_index :subject_classifications, :subject_id
    add_index :subject_classifications, :classification_id
  end
  
  def self.down
    remove_index :subject_classifications, :classification_id
    remove_index :subject_classifications, :subject_id
    drop_table :subject_classifications
  end
end
