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
                    employees: {department_id: dep.id}
                                                )
      stat.salary = monthsSalaries.sum("salary") + monthsSalaries.sum("retention")
      stat.tax = monthsSalaries.sum("NDFL") + monthsSalaries.sum("tax")
      stat.bonus = monthsSalaries.sum("bonus")
      stat.avg_salary = monthsSalaries.average("salary")+monthsSalaries.average("retention")

    #  get manager fio
      stat.manager = dep.get_manager_fio

      stat.employee_count = dep.calc_employee_count
      stat.vacancy_count = Vacancies.where(for_date: for_date.at_beginning_of_month..for_date.at_end_of_month,
                            department_id: dep.id).count("id")
      stat.save
    end

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
      avg = {'name'=>'Средняя зарплата', 'data' => Array.new, 'tooltip'=>  {"valueSuffix"=>" руб"}, "type"=>'spline',"yAxis" => 1}
      EmployeeStatsDepartments.where(month: m.month).each do |s|
        result[@standalone_month_names[m.month.month]][cat].push(Department.find(s.department_id).name)
        avg['data'].push(s.avg_salary.round 2)
        bonus['data'].push(s.bonus)
        tax['data'].push(s.tax)
        salary['data'].push(s.salary)
      end
      result[@standalone_month_names[m.month.month]][data].push(tax)
      result[@standalone_month_names[m.month.month]][data].push(bonus)
      result[@standalone_month_names[m.month.month]][data].push(salary)
      result[@standalone_month_names[m.month.month]][data].push(avg)
    end
    return result
  end
end
