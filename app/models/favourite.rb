class Favourite < ActiveRecord::Base
  attr_accessible :subject_id
  
  belongs_to :zooniverse_user
  belongs_to :subject
  
  validates_presence_of :zooniverse_user_id
  validates_presence_of :subject_id
  
  before_create :ensure_associated
  
  default_scope order('created_at asc')
  scope :between_dates, lambda { |from, to| where('created_at > ? and created_at < ?', from, to) }
  scope :for_user, lambda { |user| where(:zooniverse_user_id => user.id) }
  paginates_per 20
  
  private
  
  def ensure_associated
    ZooniverseUser.exists?(zooniverse_user_id) && Subject.exists?(subject_id)
  end
end
