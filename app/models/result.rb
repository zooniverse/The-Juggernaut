class Result < ActiveRecord::Base
  has_many :result_subjects, :dependent => :destroy
  has_many :subjects, :through => :result_subjects
  
  validates_presence_of :value
end
