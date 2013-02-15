require 'test_helper'

class TrainingTest < ActiveSupport::TestCase
  context "A training" do
    should belong_to :zooniverse_user
    
  end
end
