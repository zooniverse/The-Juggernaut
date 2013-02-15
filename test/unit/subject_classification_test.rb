require 'test_helper'

class SubjectClassificationTest < ActiveSupport::TestCase
  context "A subject classification" do
    should belong_to :subject
    should belong_to :classification
  end
end
