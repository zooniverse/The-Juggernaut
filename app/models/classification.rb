class Classification < ActiveRecord::Base
  has_many :subject_classifications, :dependent => :destroy
  has_many :subjects, :through => :subject_classifications
  has_many :annotations, :dependent => :destroy
  
  belongs_to :zooniverse_user
  belongs_to :workflow
  
  validates_presence_of :zooniverse_user_id
  validates_presence_of :workflow_id
  validates_presence_of :locale
  validates_presence_of :started
  validates_presence_of :ended
  
  after_create :increment_user_activity_count
  before_destroy :decrement_user_activity_count
  
  def calculate_score
    answers = []
    
    annotations.each do |annotation|
      answers << annotation.answer if annotation.answer
    end
    
    total = 0
    answers.each do |a|
      total = total + a.score if a.score
    end
    update_attribute(:total_score, total)
  end
  
  def self.in_period(from, to)
    count(:all, :conditions => ['created_at > ? AND created_at < ?', from, to])
  end
  
  def increment_user_activity_count
    zooniverse_user.update_activity_count(workflow_id, true)
  end
  
  def decrement_user_activity_count
    zooniverse_user.update_activity_count(workflow_id, false)
  end
  
  def update_subject_classification_count
    subjects.each do |subject|
      Subject.increment_counter(:classification_count, subject.id)
    end
  end
  
  def subject
    subjects.first
  end
  
  def self.create_with_subjects_and_annotations(incoming)
    subjects = incoming.delete(:subjects)
    annotations = incoming.delete(:annotations)
    classification = Classification.new(incoming)
    
    if classification.save
      # Create the subject_classification association and annotations
      begin
        subjects.each do |a|
          subject = Subject.find(a[:id])
          classification.subjects << subject
        end
        
        #check that there are some annotations!
        if annotations.empty?
          saved = false
          classification.destroy
        else #we have some annotations :-)
          annotations.each do |ann|
            annotation = Annotation.new(ann)
            
            unless classification.annotations << annotation
              raise 'Problem saving the annotation - invalid response?'
            end
          end
          
          classification.update_subject_classification_count
          classification.calculate_score if scoring?
          classification.calculate_subject_averages if scoring?
          saved = true
        end
      rescue
        saved = false
        classification.destroy
      end
    end
    
    saved
  end
  
  def calculate_subject_averages
    subjects.each do |subject|
      subject.update_attribute(:average_score, subject.classifications.average(:total_score).to_f)
    end
  end
  
  def self.scoring?
    SiteConfig.scoring
  end
end
