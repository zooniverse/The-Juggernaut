class GroupMember < ActiveRecord::Base
  belongs_to :group
  belongs_to :member, :class_name => 'ZooniverseUser', :foreign_key => 'member_id'
end
