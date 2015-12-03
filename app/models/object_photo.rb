class ObjectPhoto < ActiveRecord::Base
  ObjectPhoto.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfoPhotoList"
  self.primary_key = "PhotoID"

  has_one :obj, foreign_key: "ObjId"

  alias_attribute "id","PhotoID"
  alias_attribute "photo_name","PhotoName"
  alias_attribute "object_id","ObjID"
  alias_attribute "mime_type","MimeType"
  alias_attribute "photo_date","PhotoDate"
  alias_attribute "url","URL"

  def date
    return Date.parse (self.photo_date.to_s)
  end

  def get_big_photo
    return MiniMagick::Image.open("/var/www/pictures/#{object_id}/#{id}_b.jpg").to_blob
  end

  def save_photos
    if (File.exist?("/var/www/pictures/#{object_id}/#{id}_b.jpg") &&
        File.exist?("/var/www/pictures/#{object_id}/#{id}_s.jpg"))
      puts "file already exists. Skipping…"
      return
    end
    require "open-uri"
    require 'fileutils'
    need_sizes = [1024,768]
    image = MiniMagick::Image.open(url)
    size = image.dimensions
    scale = 2
    if (size[0]>size[1])
      scale = need_sizes[0]*1.0/size[0]
    else
      scale = need_sizes[1]*1.0/size[1]
    end
    image.resize "#{size[0]*scale}x#{size[1]*scale}"
    unless File.directory?("/var/www/pictures/#{object_id}")
      FileUtils.mkdir_p("/var/www/pictures/#{object_id}")
    end
    image.write "/var/www/pictures/#{object_id}/#{id}_b.jpg"

    need_sizes = [300,200]
    size = image.dimensions
    scale = 2
    if (size[0]>size[1])
      scale = need_sizes[0]*1.0/size[0]
    else
      scale = need_sizes[1]*1.0/size[1]
    end
    image.resize "#{size[0]*scale}x#{size[1]*scale}"
    image.write "/var/www/pictures/#{object_id}/#{id}_s.jpg"
    puts "create files for object #{object_id} done…"
  end

  def get_small_photo
    return MiniMagick::Image.open("/var/www/pictures/#{object_id}/#{id}_s.jpg").to_blob
  end

  def small_photo_url
    return "http://213.85.34.118:50080" + "/pictures/#{self.object_id}/#{self.id}_s.jpg"
  end
  def big_photo_url
    return "http://213.85.34.118:50080" + "/pictures/#{self.object_id}/#{self.id}_b.jpg"
  end

  def self.objects_photos
    values = []
    last_dates = []
    Obj.each do |object|
      d = ObjectPhoto.select('MAX(CAST(PhotoDate AS DATE)) as max_date').group('ObjID').where("ObjID = ?", object.id).take
      last_date = d.max_date if d.present?
      values.concat ObjectPhoto.photos_by_object_and_date object.id, last_date if last_date.present?
    end
    values
  end

  def self.photos_by_object_and_date obj_id, date
    values = []
    ObjectPhoto.where('PhotoDate >= ?', date).where(object_id: obj_id).each do |p|
      values << {
          object_id: p.object_id,
          preview_url: p.small_photo_url,
          full_image_url: p.big_photo_url,
          date: p.date.to_time.to_i
      }
    end
    values
  end
end