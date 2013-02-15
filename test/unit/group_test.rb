require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  context "A Group" do
    should belong_to :focus
    should have_many :group_members
    should have_many(:members).through(:group_members)
  end  
end
