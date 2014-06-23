class Employee < ActiveRecord::Base
  belongs_to :department, inverse_of: :employees
  has_one :manage, class_name: "Department", foreign_key: "chief_id"

  has_many :salaries, class_name: "Salary", foreign_key: "employee_id"
  has_many :flows, class_name: "PersonalFlow", foreign_key: "employee_id"

  POSTMANAGER = "Начальник управления"
  POSTMANAGERALTERNATE = "Заместитель начальника управления"
  POSTMANAGERSIMPLE = "Начальник"
  POSTGENDIRECTOR = "Генеральный директор"
  POSTZAMGENDIR = "Первый заместитель генерального директора"
  POSTDIRSIMPLE = "директор"

  #QueryStringManagersAndAlternate = "post like '#{POSTMANAGERSIMPLE}%' or post like '#{POSTMANAGERALTERNATE}%'" +
  #                                  "or post like '#{POSTGENDIRECTOR}' or post like '#{POSTZAMGENDIR}%'"
  QueryStringManagersAndAlternate = "(post like '#{POSTMANAGERSIMPLE}%' or post like '%#{POSTDIRSIMPLE}%')"


  FLOWDISMISSTYPE = "Увольнение"
  FLOWADDTYPE = "Прием на работу"
  FLOWTRANSFERTYPE = "Перемещение"

  def self.get_managers_count
      return get_managers.count
  end

  def self.get_managers
    return Employee.joins("JOIN departments ON departments.id = employees.department_id and "+
                              "departments.parent_id ISNULL AND "+QueryStringManagersAndAlternate)
    #return Employee.where(QueryStringManagersAndAlternate)
  end

  def self.get_managers_ids
    ids = Array.new
    Employee.where(QueryStringManagersAndAlternate).each do |e|
      ids.push(e.id)
    end
    return ids
  end

  def self.dismiss_employee (tab_number, date_of_operation, old_post, old_department_out_number)
    department_id = nil
    empl_id = nil
    empl = Employee.find_by tab_number: tab_number
    if empl == nil
      puts "НЕ НАЙДЕН СОТРУДНИК С ТАБЕЛЬНЫМ НОМЕРОМ #{tab_number} ДЛЯ УВОЛЬНЕНИЯ"
    else
      empl_id = empl.id
    end
    dep = Department.find_by_out_number(old_department_out_number)
    if (dep != nil)
      department_id = dep.id
    end
    PersonalFlow.create(operation_type: FLOWDISMISSTYPE,
                        old_post: old_post,
                        flow_date: date_of_operation,
                        employee_id: empl_id,
                        old_department_id: department_id)
    if empl!=nil
      empl.destroy
    end
    puts "Уволен сотрудник с табельным номером #{tab_number} из подразделения с id #{old_department_out_number}"
  end

  def self.add_employee (fio, tab_number, new_post, stavka, new_dep_out_id, date_of_operation)
    dep = Department.find_by out_number: new_dep_out_id
    department_id = nil
    if dep == nil
      puts "НЕ НАЙДЕН ДЕПАРТАМЕНТ С ID = #{new_dep_out_id} В КОТОРЫЙ ПРИНЯТ СОТРУДНИК #{tab_number}"
    else
      department_id = dep.id
    end
    empl = Employee.find_by tab_number: tab_number
    if empl != nil
      puts "СОТРУДНИК С ТАБЕЛЬНЫМ НОМЕРОМ #{tab_number} УЖЕ СУЩЕСТВУЕТ! НЕВОЗМОЖНО ПРИНЯТЬ НА РАБОТУ"
    else
      empl = Employee.create(FIO: fio, tab_number: tab_number, stavka:stavka,
                                      post: new_post, department_id: department_id)
    end
    PersonalFlow.create(operation_type: FLOWADDTYPE,
                        new_post: new_post,
                        flow_date: date_of_operation,
                        employee: empl,
                        new_department_id: department_id)
    puts "ПРИНЯТ НА РАБОТУ СОТРУДНИК #{empl.attributes}"
  end

  def self.transfer_employee (tab_number, new_post, stavka, date_of_operation, new_dep_out_id, post)
    empl_id = nil
    old_dep = nil
    new_dep = nil
    old_post = nil
    empl = Employee.find_by tab_number: tab_number
    new_department = Department.find_by out_number: new_dep_out_id
    if empl!=nil && new_department != nil
      old_post = empl.post
      empl_id = empl.id
      old_dep = empl.department_id
      new_dep = new_department.id
      empl.department_id = new_department.id
      empl.stavka = stavka
      empl.post = post
      empl.save
      puts "ПЕРВОД #{empl.attributes}"
    end
    PersonalFlow.create(operation_type: FLOWTRANSFERTYPE,
                           old_post: old_post,
                           new_post: new_post,
                           flow_date: date_of_operation,
                           employee_id: empl_id,
                           new_department_id: new_dep,
                           old_department_id: old_dep)

  end
end
