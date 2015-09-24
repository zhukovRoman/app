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
    puts Time.current , "resize image compl"

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
  end

  def get_small_photo
    return MiniMagick::Image.open("/var/www/pictures/#{object_id}/#{id}_s.jpg").to_blob
    # require "open-uri"
    # need_sizes = [300,200]
    # image = MiniMagick::Image.open(self.url)
    # size = image.dimensions
    # scale = 2
    # if (size[0]>size[1])
    #   scale = need_sizes[0]*1.0/size[0]
    # else
    #   scale = need_sizes[1]*1.0/size[1]
    # end
    # image.resize "#{size[0]*scale}x#{size[1]*scale}"
    # return image.to_blob
  end

  def small_photo_url
    return "http://localhost:3000" + "/api/get_object_image?id=#{self.id}&size=small"
  end
  def big_photo_url
    return "http://localhost:3000" + "/api/get_object_image?id=#{self.id}&size=big"
  end
end