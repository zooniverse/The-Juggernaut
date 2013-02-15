class CreateResultSubjects < ActiveRecord::Migration
  def self.up
    create_table :result_subjects, :force => true do |t|
      t.integer :subject_id
      t.integer :result_id
      t.timestamps
    end
    
    add_index :result_subjects, :subject_id
    add_index :result_subjects, :result_id
  end
  
  def self.down
    remove_index :result_subjects, :result_id
    remove_index :result_subjects, :subject_id
    mind
    drop_table :result_subjects
  end
end
