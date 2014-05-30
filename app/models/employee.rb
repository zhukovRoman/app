class Employee < ActiveRecord::Base
  belongs_to :department, inverse_of: :employees
  has_one :manage, class_name: "Department", foreign_key: "chief_id"

  has_many :salaries, class_name: "Salary", foreign_key: "employee_id"
  has_many :flows, class_name: "PersonalFlow", foreign_key: "employee_id"
end
