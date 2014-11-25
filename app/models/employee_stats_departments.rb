class EmployeeStatsDepartments < ActiveRecord::Base
  belongs_to :department, inverse_of: :stats

  def self.calculate_stat (for_date)

    Department.get_top_department.each do |dep|
      stat = EmployeeStatsDepartments.where(month: for_date.at_beginning_of_month..for_date.at_end_of_month,
                                            department_id: dep.id).take
      if (stat == nil)
        stat = EmployeeStatsDepartments.create(month: for_date.at_beginning_of_month+14.day, department: dep)
      end
      monthsSalaries = Salary.joins(:employee).where(
                    salaries: {salary_date: for_date.at_beginning_of_month..for_date.at_end_of_month},
                    employees: {department_id: dep.getIdsSelfAndChilds, is_delete: 0}).
                    where.not(employees: {FIO: 'empty'})

        stat.salary = monthsSalaries.sum("salary") + monthsSalaries.sum("retention")
        stat.tax = monthsSalaries.sum("NDFL") + monthsSalaries.sum("tax")
        stat.bonus = monthsSalaries.sum("bonus")
        avg_salary = monthsSalaries.average("salary")!=nil ? monthsSalaries.average("salary") : 0
        avg_retention = monthsSalaries.average("retention") != nil ? monthsSalaries.average("retention") : 0
        #puts "----------#{avg_salary}------------"
        #puts "----------#{avg_retention}------------"
        #puts "----------#{avg_salary+avg_retention}------------"
        stat.avg_salary = avg_salary  + avg_retention




    #  get manager fio
      stat.manager = dep.get_manager_fio
      stat.dep_name = dep.name
      stat.employee_count = dep.calc_employee_count
      Vacancies.fill_empty_vac for_date
      stat.vacancy_count = Vacancies.where(for_date: for_date.at_beginning_of_month..for_date.at_end_of_month,
                            department_id: dep.id).take.count
      stat.save
    end

  end

  def self.getMonthsEmployeesCounts
    standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    res = Hash.new
    EmployeeStatsDepartments.select(:month).distinct.each do |m|
      res[standalone_month_names[m.month.month]] = Array.new
      EmployeeStatsDepartments.where(month: m.month).where('employee_count>0').each do |s|
        res[@standalone_month_names[m.month.month]].push(s.employee_count)
      end
    end
    return res
  end

  def self.get_data_for_drilldown
    cat = 'categories'
    data = 'data'
    @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    result = Hash.new
    EmployeeStatsDepartments.select(:month).distinct.each do |m|

      result[@standalone_month_names[m.month.month]] = Hash.new
      result[@standalone_month_names[m.month.month]][cat] = Array.new
      result[@standalone_month_names[m.month.month]][data] = Array.new
      salary = {'name'=>'Зарплата', 'data' => Array.new, 'tooltip'=>  {"valueSuffix"=>" руб"}}
      tax = {'name'=>'Налоги', 'data' => Array.new, 'tooltip'=>  {"valueSuffix"=>" руб"}}
      bonus = {'name'=>'Премии', 'data' => Array.new, 'tooltip'=>  {"valueSuffix"=>" руб"}}
      avg = {'name'=>'Средняя зарплата', 'data' => Array.new, 'tooltip'=>  {"valueSuffix"=>" "}, "type"=>'spline',"yAxis" => 1}
      EmployeeStatsDepartments.where(month: m.month).where('employee_count>0').each do |s|
        puts s.attributes
        result[@standalone_month_names[m.month.month]][cat].push(Department.find(s.department_id).name)
        avg['data'].push((s.salary/s.employee_count).round 0)
        bonus['data'].push(s.bonus.round 0)
        tax['data'].push(s.tax.round 0)
        salary['data'].push(s.salary.round 0)
      end
      result[@standalone_month_names[m.month.month]][data].push(tax)
      result[@standalone_month_names[m.month.month]][data].push(bonus)
      result[@standalone_month_names[m.month.month]][data].push(salary)
      result[@standalone_month_names[m.month.month]][data].push(avg)
    end
    return result
  end

  def self.fillCurrentMonth
    Department.where(:parent_id => nil).each do |dep|
      EmployeeStatsDepartments.create(month: Date.current.at_beginning_of_month+15.day,
                                      department_id:dep.id,
                                      salary: 0)
    end
  end
end
