class PersonalFlow < ActiveRecord::Base
  has_one :old_department, class_name: "Department", inverse_of: :flow_from
  has_one :new_department, class_name: "Department", inverse_of: :flow_to
  belongs_to :employee, class_name:"Employee", inverse_of: :flows
end
