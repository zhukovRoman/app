module Api
  module V1
    class StaffsController < ApiController
      # GET /api/v1/staff
      #
      def index
        @response_object = Staff.new
        render render_options
      end
    end
  end
end