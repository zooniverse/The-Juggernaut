# rake classifications:clear
namespace :classifications do

  desc "Clear the classifications and favourites."
  task :clear => :environment do |t, args|

    puts
    puts "Clearing classifications and favourites..."

    Classification.destroy_all

    Favourite.destroy_all

    puts
    puts "...done."
    puts

  end # :clear

end
