class ZooniverseUser < ActiveRecord::Base
  has_many :classifications
  has_many :favourites
  has_many :groups, :as => :focus
  has_many :activities
  
  set_primary_key 'zooniverse_user_id'
  
  paginates_per 10
  
  def update_activity_count(workflow_id, incrementing = true)
    activity = activities.find_or_initialize_by_workflow_id(workflow_id)
    return if activity.new_record? && !incrementing
    incrementing ? activity.increment!(:counter) : activity.decrement!(:counter)
  end
  
  def last_active_at
    last_classification.created_at
  end
  
  def last_classified
    last_classification.subject
  end
  
  private
  def last_classification
    classifications.last || Classification.new
  end
end
