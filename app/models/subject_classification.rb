class SubjectClassification < ActiveRecord::Base
  belongs_to :classification
  belongs_to :subject
end
