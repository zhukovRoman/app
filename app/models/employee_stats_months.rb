class EmployeeStatsMonths < ActiveRecord::Base

  def self.calculate_stat (for_date)
    stat = EmployeeStatsMonths.where( month: for_date.at_beginning_of_month..for_date.at_end_of_month).take
    if (stat == nil)
      stat = EmployeeStatsMonths.create(month: for_date.at_beginning_of_month+14.day)
    end

    #calc salary
    monthsSalaries = Salary.where(salary_date: for_date.at_beginning_of_month..for_date.at_end_of_month)
    stat.salary = monthsSalaries.sum("salary") + monthsSalaries.sum("retention")
    stat.tax = monthsSalaries.sum("NDFL") + monthsSalaries.sum("tax")
    stat.bonus = monthsSalaries.sum("bonus")
    #avg_salary = monthsSalaries.average("salary")!=nil ? monthsSalaries.average("salary") : 0
    avg_salary = monthsSalaries.sum("salary")/Employee.get_real_count_of_employees
    avg_retention = monthsSalaries.average("retention") != nil ? monthsSalaries.average("retention") : 0
    stat.avg_salary = avg_salary  + avg_retention
    #stat.avg_salary = monthsSalaries.average("salary")+monthsSalaries.average("retention")

    #calc employee flow
    stat.employee_count = Employee.get_real_count_of_employees
    personalFlows = PersonalFlow.where(flow_date: for_date.at_beginning_of_month..for_date.at_end_of_month)
                                .where.not(flow_date: for_date.at_beginning_of_year)
                                .where.not(flow_date: for_date.at_end_of_year)

    stat.employee_adds = personalFlows.where(operation_type: "Прием на работу").count
    stat.employee_dismiss = personalFlows.where(operation_type: "Увольнение").count

    #calc vacancy
    stat.vacancy_count = Vacancies.where(for_date: for_date.at_beginning_of_month..for_date.at_end_of_month).sum("count")

    #calc koef
    stat.k_dismiss = stat.employee_dismiss.to_f/stat.employee_count
    stat.k_complect = stat.vacancy_count.to_f/stat.employee_count

    #calc manage stats
    stat.employee_manage_count = Department.calc_employee_count_by_type(0)+Employee.get_managers_count
    stat.employee_production_count=Department.calc_employee_count_by_type(1)-Employee.get_managers_count

    managersMonthSalaries = Salary.where(salary_date: for_date.at_beginning_of_month..for_date.at_end_of_month,
                                        employee_id: Employee::get_managers_ids)
    stat.salary_manage = managersMonthSalaries.sum("salary") + managersMonthSalaries.sum("retention")
    stat.tax_manage = managersMonthSalaries.sum("NDFL")+managersMonthSalaries.sum("tax")
    stat.bonus_manage = managersMonthSalaries.sum("bonus")
    avg_m_salary = managersMonthSalaries.average("salary") != nil ? managersMonthSalaries.average("salary") : 0
    avg_m_retention = managersMonthSalaries.average("retention") != nil ? managersMonthSalaries.average("retention") : 0
    stat.avg_salary_manage = avg_m_salary + avg_m_retention
    stat.AUP_count = Employee::get_managers_count
    stat.save
    return stat
  end
end
