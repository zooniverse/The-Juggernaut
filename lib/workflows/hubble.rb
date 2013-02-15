# Just demonstrating that this DSL actually makes life better
# You can run it with rake workflow:execute[hubble]
# Check out the workflow rake task for more options

def dust_helper
  "Dust lane"
end

WorkflowCreator.new(:name => "Galaxy Zoo Hubble", :details => "The primary classification tree", :default => true, :validate => true) do
  # specify your first question with starts_with
  starts_with "Is the galaxy simply smooth and rounded, with no sign of a disk?" do
    answer "Smooth", :leads_to => "How rounded is it?"
    answer "Features or disk", :leads_to => "Does the galaxy have a mostly clumpy appearance?"
    answer "Star or artifact", :leads_to => :end  # This ends the workflow
  end
  
  # If all question answers lead to the same question, you can specify it as a default option on the question
  question "How rounded is it?", :leads_to => "Is there anything odd?" do
    answer "Completely round"
    answer "In between"
    answer "Cigar shaped"
  end
  
  # You can call it a task instead of a question if you're so inclined
  task "Is there anything odd?" do
    answer "Yes", :leads_to => "Is the odd feature a ring, or is the galaxy disturbed or irregular?"
    answer "No"  # An answer without a :leads_to option defaults to :end
  end
  
  question "Is the odd feature a ring, or is the galaxy disturbed or irregular?" do
    answer "Ring"
    answer "Lens or arc"
    answer "Disturbed"
    answer "Irregular"
    answer "Other"
    answer "Merger"
    answer dust_helper  # method calls can escape the DSL's context too
  end
  
  question "Does the galaxy have a mostly clumpy appearance?" do
    answer "Yes", :leads_to => "How many clumps are there?"
    answer "No", :leads_to => "Could this be a disk viewed edge-on?"
  end
  
  # You can have a default next question and then override it for individual answers
  question "How many clumps are there?", :leads_to => "Do the clumps appear in a straight line, a chain, or a cluster?" do
    answer "1", :leads_to => "Does the galaxy appear symmetrical?"
    answer "2", :leads_to => "Is there one clump which is clearly brighter than the others?"
    answer "3"
    answer "4"
    answer "More than 4"
    answer "Can't tell"
  end
  
  question "Do the clumps appear in a straight line, a chain, or a cluster?", :leads_to => "Is there one clump which is clearly brighter than the others?" do
    answer "Straight Line"
    answer "Chain"
    answer "Cluster"
    answer "Spiral"
  end
  
  question "Is there one clump which is clearly brighter than the others?" do
    answer "Yes", :leads_to => "Is the brightest clump central to the galaxy?"
    answer "No", :leads_to => "Does the galaxy appear symmetrical?"
  end
  
  question "Is the brightest clump central to the galaxy?" do
    answer "Yes", :leads_to => "Does the galaxy appear symmetrical?"
    answer "No"
  end
  
  question "Does the galaxy appear symmetrical?", :leads_to => "Do the clumps appear to be embedded within a larger object?" do
    answer "Yes"
    answer "No"
  end
  
  question "Do the clumps appear to be embedded within a larger object?", :leads_to => "Is there anything odd?" do
    answer "Yes"
    answer "No"
  end
  
  question "Could this be a disk viewed edge-on?" do
    answer "Yes", :leads_to => "Does the galaxy have a bulge at its centre? If so, what shape?"
    answer "No", :leads_to => "Is there a sign of a bar feature through the centre of the galaxy?"
  end
  
  question "Does the galaxy have a bulge at its centre? If so, what shape?", :leads_to => "Is there anything odd?" do
    answer "Rounded"
    answer "Boxy"
    answer "No bulge"
  end
  
  question "Is there a sign of a bar feature through the centre of the galaxy?", :leads_to => "Is there any sign of a spiral arm pattern?" do
    answer "Bar"
    answer "No bar"
  end
  
  question "Is there any sign of a spiral arm pattern?" do
    answer "Spiral", :leads_to => "How tightly wound do the spiral arms appear?"
    answer "No spiral", :leads_to => "How prominent is the central bulge, compared with the rest of the galaxy?"
  end
  
  question "How tightly wound do the spiral arms appear?", :leads_to => "How many spiral arms are there?" do
    answer "Tight"
    answer "Medium"
    answer "Loose"
  end
  
  question "How many spiral arms are there?", :leads_to => "How prominent is the central bulge, compared with the rest of the galaxy?" do
    answer "1"
    answer "2"
    answer "3"
    answer "4"
    answer "More than 4"
    answer "Can't tell"
  end
  
  question "How prominent is the central bulge, compared with the rest of the galaxy?", :leads_to => "Is there anything odd?" do
    answer "No bulge"
    answer "Just noticeable"
    answer "Obvious"
    answer "Dominant"
  end
end
