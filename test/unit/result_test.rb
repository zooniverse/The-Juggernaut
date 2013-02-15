require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  context "A Result" do
    should have_many(:result_subjects).dependent(:destroy)
    should have_many(:subjects).through(:result_subjects)
  end  
end
