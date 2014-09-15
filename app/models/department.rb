class Department < ActiveRecord::Base
  has_many :employees, inverse_of: :department
  has_many :stats, class_name: "employee_stats_departments", inverse_of: :department
  belongs_to :chief, inverse_of: :manage

  belongs_to :parent, class_name: "Department"
  has_many :childs , class_name: "Department", foreign_key: "parent_id"

  has_many :flow_from, class_name: "PersonalFlow", foreign_key: "old_department_id"
  has_many :flow_to , class_name: "PersonalFlow", foreign_key: "new_department_id"
  has_many :vacancies, class_name: "Vacancies", foreign_key: "department_id"

  #has_many :vacancies, class_name: "Vacancies", inverse_of: :department

  #validates :vacancy_count, numericality: { only_integer: true, :message =>  " должно быть целым числом!" }

  def calc_employee_count

    count = self.employees.where.not(FIO: 'empty').count
    self.childs.each do |child|
      count = count + child.calc_employee_count
    end
    return count;
  end

  def getIdsSelfAndChilds
    res = Array.new
    res.push (self.id)
    self.childs.each do |dep|
      res.push (dep.getIdsSelfAndChilds)
    end
    return res;
  end

  def self.calc_employee_count_by_type (type)
    count = 0
    Department.where(parent_id:  nil, department_type: type).each do |dep|
      count = count + dep.calc_employee_count
    end
    return count
  end

  def self.get_top_department
    return Department.where(parent_id:  nil)
  end

  def get_manager_fio
    empl =  self.employees.where("post LIKE ? or post like ?",
                                "#{Employee::POSTMANAGERSIMPLE}%", "#{Employee::POSTGENDIRECTOR}%" ).take
    return empl!=nil ? empl.FIO : "-"
  end

  def shortName
    return (name.length < 35) ? name : name[0,35]+"…"
  end

  def self.createDepartmentFromXML(departmentNode)
    if (departmentNode.name()=="sector")
      # ищем департамент для сектора
      dep = Department.find_by out_number:departmentNode.parent.attribute('id').inner_text()
      if dep!=nil
        return Department.create(name: departmentNode.attribute('name').to_s, vacancy_count: 0,
                                 out_number: departmentNode.attribute('id').to_s , parent: dep)
      else
      #  такого департамента нет - надо искать управление
        departmentXMLNode = departmentNode.parent
        directorate = Department.find_by out_number:departmentXMLNode.attribute('id').inner_text()
        if directorate==nil
          #  создаем управление
          directorate = Department.create(name: departmentXMLNode.parent.attribute('name').to_s, vacancy_count: 0,
                                        out_number: departmentXMLNode.parent.attribute('id').to_s , parent: nil)
        end
        # создаем департамент
        department = Department.create(name: departmentXMLNode.attribute('name').to_s, vacancy_count: 0,
                                       out_number: departmentXMLNode.attribute('id').to_s , parent: directorate)
        return Department.create(name: departmentNode.attribute('name').to_s, vacancy_count: 0,
                                 out_number: departmentNode.attribute('id').to_s , parent: department)
      end
    end
    if departmentNode.name()=="department"
      #  ищем управление для депаратамента
      departmentXMLNode = departmentNode.parent
      directorate = Department.find_by out_number:departmentXMLNode.attribute('id').inner_text()
      if directorate==nil
        #  создаем управление
        directorate = Department.create(name: departmentXMLNode.parent.attribute('name').to_s, vacancy_count: 0,
                                        out_number: departmentXMLNode.parent.attribute('id').to_s , parent: nil)
      end
      # создаем департамент
       return Department.create(name: departmentXMLNode.attribute('name').to_s, vacancy_count: 0,
                                     out_number: departmentXMLNode.attribute('id').to_s , parent: directorate)
    end
    if departmentNode.name()=="directorate"
      return Department.create(name: departmentNode.attribute('name').to_s, vacancy_count: 0,
                        out_number: departmentNode.attribute('id').to_s , parent: nil)
    end

  end


end
