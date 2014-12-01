# rake subjects:load[subjects_dir]
# rake subjects:clear[subjects_dir]
namespace :subjects do

  desc "Load the subjects from a directory."
  task :load, [:subjects_dir] => :environment do |t, args|

    ensure_dir_in args

    dir_path = dir_path_from args

    puts
    puts "Loading subjects..."
    puts

    puts "* Directory containing subjects: '#{dir_path}'"

    ## Array of the files found in the directory supplied.
    files = Dir[dir_path + "/*"].sort

    ## File counter (HACK).
    i = 0

    files.each do |fn|
      name = File.basename(fn)
      location = "#{args[:subjects_dir]}/#{name}"
      id = "AGZ%06d" % [i]
      puts "*--> Adding: '#{name}' to '#{location}' with ID #{id}"
      Subject.create(
          :name => name,
          :location => location,
          :thumbnail_location => location,
          :active => true,
          :workflow_id => 1,
          :zooniverse_id => id
        )
      i += 1
    end
    puts
    puts "...done."
    puts

  end # subjects:load


  desc "Clear the subjects from a directory."
  task :clear, [:subjects_dir] => :environment do |t, args|

    ensure_dir_in args

    dir_path = dir_path_from args

    puts
    puts "Clearing subjects..."
    puts

    puts "* Directory to be cleared: '#{dir_path}'"
    puts "*"

    files = Dir[dir_path + "/*"]

    # List the subjects.
    puts "* Subjects currently loaded:"
    Subject.all.each do |s|
      puts "*--> '#{s.name}'."
    end
    puts

    files.each do |fn|
      name = File.basename(fn)
      puts "* '#{name}'"
      # Find the subjects listed in the directory.
      Subject.where("name = ?", name).each do |found|
        puts "*--> Found in database - DESTROYING!"
        found.destroy
      end
    end
    puts

    # List the subjects after deletion.
    puts "Subjects now loaded:"
    Subject.all.each do |s|
      puts "* '#{s.name}'."
    end
    puts "*"
    puts
    puts "...done."

  end

end

def ensure_dir_in(args)
  raise "ERROR: No directory specified." if args[:subjects_dir].blank?
end

def dir_path_from(args)
  "#{ Rails.root }/app/assets/images/#{ args[:subjects_dir] }/"
end
