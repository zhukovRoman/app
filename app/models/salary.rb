class Salary < ActiveRecord::Base
  belongs_to :employee, inverse_of: :salaries
end
