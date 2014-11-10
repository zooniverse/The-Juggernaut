# rake classifications:clear
namespace :classifications do

  desc "Clear the classifications and favourites."
  task :clear => :environment do |t, args|

    puts
    puts "Clearing classifications and favourites..."

    Classification.all.each do |cl|
      cl.destroy
    end

    Favourite.all.each do |fv|
      fv.destroy
    end

    puts "...done."
    puts

  end # :clear

end
