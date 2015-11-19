
module Api
  module V1
    class FlatsController < ApiController
      # GET /api/v1/contractors
      #
      def index
        res = Flat.new
        @response_object = {
            # flat: res.flats,
            # flatObject: res.objects,
            # flatStatus: res.statuses,
            # flatDkpExpectedDate: res.dkp_expected,
            # flatRealtorCommission: res.fee
                            }
        render render_options
      end
    end
  end
end
