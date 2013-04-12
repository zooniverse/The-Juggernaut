desc "Create a new WorkflowCreator"
task :load_test_subjects => :environment do
  (1..4).each do |i|
    Subject.create(
        :name => "#{i}.jpg",
        :location => "subjects/#{i}.jpg",
        :thumbnail_location => "subjects/#{i}.jpg",
        :active => true,
        :workflow_id => 1,
        :zooniverse_id => "AGZ00000#{i}"
      )
  end
end