class CreateGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :group_members, :force => true do |t|
      t.integer :group_id
      t.integer :member_id
      t.timestamps
    end
    
    add_index :group_members, :group_id
    add_index :group_members, :member_id
  end
  
  def self.down
    remove_index :group_members, :member_id
    remove_index :group_members, :group_id
    drop_table :group_members
  end
end
