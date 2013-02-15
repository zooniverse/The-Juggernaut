# rake workflow:new[file_name]
# edit edit edit
# rake workflow:execute[file_name]
namespace :workflow do
  desc "Create a new WorkflowCreator"
  task :new, [:name] do |t, args|
    ensure_name_in args
    
    file_path = file_path_from args
    ensure_file_doesnt_exist file_path
    
    File.open(file_path, 'w') do |f|
      f.puts <<-EVAL
WorkflowCreator.new(:name => "#{ args[:name] }", :details => "", :default => true, :validate => true) do
  starts_with "Your first question" do
    answer "answer 1", :leads_to => "Your next question"
    answer "answer 2", :leads_to => "Your next question"
    answer "answer 3", :leads_to => :end
  end
  
  task "Your next question" do
    answer "answer 1"
    answer "answer 2"
  end
end
      EVAL
    end
  end
  
  desc "Execute a WorkflowCreator"
  task :execute, [:name] => :environment do |t, args|
    ensure_name_in args
    
    file_path = file_path_from args
    ensure_file_exists file_path
    
    require file_path
  end
  
  task :clear => :environment do
    puts "This will destroy all workflows, tasks, and answers in the #{ Rails.env } environment"
    puts "Are you sure you want to do this? (y/n)"
    if STDIN.gets.chomp[0].downcase == 'y'
      puts "Destroying..."
      [Workflow, WorkflowTask, WorkflowAnswer, Task, Answer].map(&:destroy_all)
      puts "Done"
    else
      puts "Skipping"
    end
  end
end

def ensure_name_in(args)
  raise "No file specified" if args[:name].blank?
end

def ensure_file_exists(file_path)
  raise "File not found: #{ file_path.inspect }" unless File.exists?(file_path)
end

def ensure_file_doesnt_exist(file_path)
  raise "File already exists: #{ file_path.inspect }" if File.exists?(file_path)
end

def file_path_from(args)
  "#{ Rails.root }/lib/workflows/#{ args[:name] }.rb"
end