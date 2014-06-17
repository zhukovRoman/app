class Department < ActiveRecord::Base
  has_many :employees, inverse_of: :department
  belongs_to :chief, inverse_of: :manage

  belongs_to :parent, class_name: "Department"
  has_many :childs , class_name: "Department", foreign_key: "parent_id"

  has_many :flow_from, class_name: "PersonalFlow", foreign_key: "old_department_id"
  has_many :flow_to , class_name: "PersonalFlow", foreign_key: "new_department_id"
  has_many :vacancies, class_name: "Vacancies", foreign_key: "department_id"

  #has_many :vacancies, class_name: "Vacancies", inverse_of: :department

  validates :vacancy_count, numericality: { only_integer: true, :message =>  " должно быть целым числом!" }
end
