module Api
  module V1
    class ObjectsController < ApiController
      # GET /api/v1/objects
      #
      def index
        @response_object = {
            # objects: Obj.api_response
        }
        render render_options
      end
    end
  end
end
