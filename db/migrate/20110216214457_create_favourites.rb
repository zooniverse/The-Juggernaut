class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites, :force => true do |t|
      t.integer :zooniverse_user_id
      t.integer :subject_id
      t.timestamps
    end
    
    add_index :favourites, :subject_id
    add_index :favourites, :zooniverse_user_id
  end
  
  def self.down
    remove_index :favourites, :zooniverse_user_id
    remove_index :favourites, :subject_id
    drop_table :favourites
  end
end
