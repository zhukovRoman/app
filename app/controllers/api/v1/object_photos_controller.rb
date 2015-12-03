module Api
  module V1
    class ObjectPhotosController < ApiController
      # GET /api/v1/objectPhotos
      #
      def index
        data = ''
        file = File.new("api_cache/objects_photos.json", "r")
        while (line = file.gets)
          data += line
        end
        file.close
        @response_object = data
        render render_options
      end
    end
  end
end


