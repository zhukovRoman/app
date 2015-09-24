namespace :photo do
  task save: :environment do
    ObjectPhoto.all.each  do |p|
     p.save_photos
    end
  end
end


