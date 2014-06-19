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
end
