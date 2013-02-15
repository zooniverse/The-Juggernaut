class Group < ActiveRecord::Base
  has_many :group_members, :dependent => :destroy
  has_many :members, :through => :group_members
  belongs_to :focus, :polymorphic => true
end
