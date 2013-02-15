require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  context "An answer" do
    should belong_to :task
    should have_many :annotations
  end
end
