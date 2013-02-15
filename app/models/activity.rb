class Activity < ActiveRecord::Base
  belongs_to :user, :class_name => 'ZooniverseUser', :foreign_key => 'zooniverse_user_id'
  belongs_to :workflow
end
