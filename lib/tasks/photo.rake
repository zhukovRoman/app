namespace :photo do
  task save: :environment do
    ObjectPhoto.all.order(:photo_date).reverse_order.each  do |p|
     p.save_photos
    end
  end
end


