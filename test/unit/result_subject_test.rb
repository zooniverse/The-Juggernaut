require 'test_helper'

class ResultSubjectTest < ActiveSupport::TestCase
  context "A ResultSubject" do
    should belong_to :subject
    should belong_to :result
  end
end
