class WorkflowCreator
  def starts_with(*args, &block)
    @starting = task *args, :starting => true, &block
  end
  
  def task(*args, &block)
    opts = { :has_defined_answer => false }.update(args.extract_options!)
    @task = Task.find_or_create_by_name(args.first, :has_defined_answer => opts[:has_defined_answer] || block_given?)
    @leads_to = opts[:leads_to]
    capture_and_eval &block
    @leads_to = nil
    @task
  end
  alias_method :question, :task
  
  def answer(*args, &block)
    opts = { :leads_to => @leads_to || :end }.update(args.extract_options!)
    @answer = @task.answers.find_or_create_by_value(args.first) { |t| t.details = args.second || "" }
    @path[@answer.id] = opts[:leads_to]
    capture_and_eval &block
    @answer
  end
  
  def initialize(*args, &block)
    opts = { :name => "Workflow name", :details => "Workflow details", :default => false, :validate => false }.update(args.extract_options!)
    @path = { }
    @tasks = [ ]
    
    @workflow = Workflow.find_or_create_by_name(:name => opts[:name], :details => opts[:details], :default => opts[:default])
    capture_and_eval &block
    
    workflow_task @starting, nil
    validate_workflow if opts[:validate]
  end
  
  private
  
  def validate_workflow
    # TO-DO
  end
  
  def workflow_task(task, parent_id)
    selector = WorkflowTask.where(:workflow_id => @workflow.id, :task_id => task.id, :parent_id => parent_id)
    
    if selector.exists?
      selector.first
    else
      wf_task = selector.create(:task_id => task.id, :parent_id => parent_id)
      task.answers.each do |unlinked_answer|
        workflow_answer wf_task, unlinked_answer
      end
      
      wf_task
    end
  end
  
  def workflow_answer(wf_task, unlinked_answer)
    wf_answer = wf_task.workflow_answers.create(:answer => unlinked_answer)
    next_task = @path[unlinked_answer.id]
    
    unless next_task == :end
      wf_answer.update_attributes :next_workflow_task_id => workflow_task(Task.find_by_name(next_task), wf_task.id).id
    end
    
    wf_answer
  end
  
  def capture_and_eval(&block)
    return unless block_given?
    @external_self = eval "self", block.binding
    instance_eval(&block)
  end
  
  def method_missing(method, *args, &block)
    @external_self.send method, *args, &block
  end
end
