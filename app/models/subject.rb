class Subject < ActiveRecord::Base
  attr_accessor :upload_errors
  
  has_many :subject_classifications
  has_many :classifications, :through => :subject_classifications
  has_many :favourites
  has_many :result_subjects
  has_many :results, :through => :result_subjects
  has_many :groups, :as => :focus
  
  validates_presence_of :name
  
  scope :recent, lambda { |*args| order('created_at desc').where('created_at > ?', args.first || SiteConfig.subject_timeframe) }
  scope :active, lambda { where(:active => true) }
  
  KNOWN_FILE_TYPES = ['application/pdf',
  'text/plain',
  'application/zip',
  'application/x-compressed',
  'application/x-zip-compressed',
  'multipart/x-zip',
  'applcation/x-tar',
  'application/x-gzip',
  'image/jpeg',
  'image/gif',
  'image/png']
  
  def update_classification_count
    Subject.increment_counter(:classification_count, id)
  end
  
  # cache all subjects (only works for a limited number with Memcache (~30,000) because of 1MB limit)
  def self.cached_subjects
    Rails.cache.fetch('all-subjects') { all }
  end
  
  def self.cached_count
    Rails.cache.fetch('subject-count') { count }
  end
  
  def self.cached_subjects_for_workflow(workflow_id)
    Rails.cache.fetch("all-subjects-task-#{ workflow_id }") { where(:workflow_id => workflow_id).all }
  end
  
  def self.cached_count_for_workflow(workflow_id)
    Rails.cache.fetch("subject-count-task-#{ workflow_id }") { count(:all, :conditions => { :workflow_id => workflow_id }) }
  end
  
  def self.next_for_classification
    # currently returns a random subject
    [ cached_subjects[rand(cached_count)] ]
  end
  
  def self.next_for_workflow(workflow_id)
    count = cached_count_for_workflow(workflow_id)
    [ cached_subjects_for_workflow(workflow_id)[rand(count)] ]
  end
  
  # This method is finding the ids of all of the subjects that the user has classified so far and then doing
  # select to find the first one that they haven't seen.
  def self.next_original_for_user(user)
    recents = joins(:classifications).where(:classifications => { :zooniverse_user_id => user.id }).select('subjects.id').all
    if recents.any?
      where(['id NOT IN (?)', recents]).first
    else
      first
    end
  end
  
  def self.supported_content_type?(incoming)
    incoming ? KNOWN_FILE_TYPES.include?(File.mime_type?(incoming).split(';').first) : false
  end
  
  def self.create_and_upload(incoming)
    create(incoming[:subject]).tap do |subject|
      subject.upload_errors = []
      subject.upload_errors << 'Invalid content type' unless supported_content_type?(incoming[:file])
      
      unless subject.upload_errors.any?
        subject.upload_errors << 'Upload failed' unless S3Uploader.upload_subject(incoming[:file], subject)
      end
      
      subject.destroy if subject.upload_errors.any?
    end
  end
end
