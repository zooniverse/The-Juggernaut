require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  context "An Activity" do
    should belong_to :user
    should belong_to :workflow
  end  
end
