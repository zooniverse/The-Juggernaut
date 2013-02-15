require 'test_helper'

class GroupMemberTest < ActiveSupport::TestCase
  context "A Group Member" do
    should belong_to :group
    should belong_to :member
  end 
end
