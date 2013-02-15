class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups, :force => true do |t|
      t.string :name
      t.text :description
      t.boolean :public
      t.integer :focus_id
      t.string :focus_type
      t.timestamps
    end
    
    add_index :groups, [:focus_id, :focus_type]
  end
  
  def self.down
    remove_index :groups, :focus_id
    drop_table :groups
  end
end