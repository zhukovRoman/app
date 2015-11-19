module Api
  module V1
    class StaffsController < ApiController
      # GET /api/v1/staff
      #
      def index
        data = ''
        file = File.new("api_cache/staffs.json", "r")
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