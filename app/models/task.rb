class Task < ActiveRecord::Base
  has_many :annotations
  has_many :answers
  
  validates_presence_of :name
  validates_uniqueness_of :name, :on => :create, :message => 'must be unique'
end
