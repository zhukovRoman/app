module Api
  module V1
    class ObjectPhotosController < ApiController
      # GET /api/v1/objectPhotos
      #
      def index
        @response_object = {
            :objectPhoto => ObjectPhoto.objects_photos
        }
        render render_options
      end
    end
  end
end


