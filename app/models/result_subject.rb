class ResultSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :result
end
