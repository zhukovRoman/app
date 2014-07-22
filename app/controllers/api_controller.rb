class ApiController < ApplicationController
  def getchart
    string = render_to_string('/employee/charts/_employee_common_scripts.js')
    render :json => string
  end
end
