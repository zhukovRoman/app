
module Api
  module V1
    class ContractorsController < ApiController
      # GET /api/v1/contractors
      #
      def index
        @response_object = {contractors: {
            :contractor => Organization.list,
            :contractorContacts => Organization.contacts,
            :contractorBudget => Organization.organizations_budjets,
            :contractorAuctionSum => Organization.organizations_parts_in_sum,
            :contractorAuctionAmount => Organization.organizations_parts_in_amount,
            :contractorPayment => Organization.organizations_payment,
            :contract => Organization.organizations_contracts
        }}
        render render_options
      end
    end
  end
end
