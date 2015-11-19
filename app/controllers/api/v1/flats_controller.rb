
module Api
  module V1
    class FlatsController < ApiController
      # GET /api/v1/contractors
      #
      def index
        data = ''
        file = File.new("api_cache/flats.json", "r")
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
