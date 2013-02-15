xml.instruct!
xml.tasks do |tasks|
  @tasks.each do |task|
    tasks.task do |t|
      t.id          task.id
      t.name        task.name
      t.subject_count task.count
    end
  end
end
