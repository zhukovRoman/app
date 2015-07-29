module Api
  class ApiController < ActionController::Base
    before_action :authenticate_with_basic
    before_action :set_default_options

    protected

    def authenticate_with_basic
      authenticate_or_request_with_http_basic do |username, password|
        # username == Api.configuration.username && password == Api.configuration.password
        username == "test" && password == "test"
      end
    end

    def callback
      params[:callback]
    end

    def set_default_options
      @default_options =  { root: false }
    end

    def render_options
      @default_options.merge! json: @response_object
      callback.present? ? @default_options.merge(callback: callback) : @default_options
    end

  end
end
