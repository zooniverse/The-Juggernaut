xml.instruct!
xml.task do |task|
  task.id   @task.id
  task.name @task.name
  
  unless @task.answers.empty?
    task.responses do |responses|
      @task.answers.each do |answer|
        responses.response answer.value
      end
    end
  end
end
