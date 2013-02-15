class Answer < ActiveRecord::Base
  belongs_to :task
  has_many :annotations
end
