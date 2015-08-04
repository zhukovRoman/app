class EmployeeStatsMonths < ActiveRecord::Base

  def self.calculate_stat (for_date)
    stat = EmployeeStatsMonths.where( month: for_date.at_beginning_of_month..for_date.at_end_of_month).take
    if (stat == nil)
      stat = EmployeeStatsMonths.create(month: for_date.at_beginning_of_month+14.day)
    end

    stat.employee_count = Employee.get_real_count_of_employees
    #calc salary
    monthsSalaries = Salary.where(salary_date: for_date.at_beginning_of_month..for_date.at_end_of_month)
    stat.salary = monthsSalaries.sum("salary") + monthsSalaries.sum("retention")
    stat.tax = monthsSalaries.sum("NDFL") + monthsSalaries.sum("tax")
    stat.bonus = monthsSalaries.sum("bonus")
    #avg_salary = monthsSalaries.average("salary")!=nil ? monthsSalaries.average("salary") : 0
    stat.avg_salary  = stat.salary/stat.employee_count
    #avg_retention = monthsSalaries.average("retention") != nil ? monthsSalaries.average("retention") : 0
    #stat.avg_salary = avg_salary  + avg_retention
    ##stat.avg_salary = monthsSalaries.average("salary")+monthsSalaries.average("retention")

    #calc employee flow

    personalFlows = PersonalFlow.where(flow_date: for_date.at_beginning_of_month..for_date.at_end_of_month)
                                .where.not(flow_date: for_date.at_beginning_of_year) # никто не увольянет 1 января
                                .where.not(flow_date: for_date.at_end_of_year) # никто не принимает и не увольняет 31 декабря

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
    #avg_m_salary = managersMonthSalaries.average("salary") != nil ? managersMonthSalaries.average("salary") : 0
    #avg_m_retention = managersMonthSalaries.average("retention") != nil ? managersMonthSalaries.average("retention") : 0
    #stat.avg_salary_manage = avg_m_salary + avg_m_retention
    #puts "------"
    #puts stat.salary_manage
    #puts Employee::get_managers_count
    stat.AUP_count = Employee::get_managers_count
    stat.avg_salary_manage = stat.salary_manage/stat.AUP_count
    stat.save
    return stat
  end

  def self.saveStatsFromSOAP responseStat
    month = Date.parse responseStat[:year]+'-'+responseStat[:month]+'-15'

    empl = EmployeeStatsMonths.where(month: month).first || EmployeeStatsMonths.new
    empl.month = month
    empl.salary = responseStat[:salary].to_i
    empl.bonus = responseStat[:bonus].to_i
    empl.avg_salary = responseStat[:salary].to_i/responseStat[:empl_count].to_i
    empl.tax = responseStat[:tax].to_i
    empl.salary_manage = responseStat[:aup_salary].to_i
    empl.bonus_manage = responseStat[:aup_bonus].to_i
    empl.tax_manage = responseStat[:aup_tax].to_i
    empl.avg_salary_manage = responseStat[:aup_salary].to_i/responseStat[:aup_empl_count].to_i
    empl.employee_count = responseStat[:empl_count].to_i
    empl.employee_adds = responseStat[:empl_add].to_i
    empl.employee_dismiss = responseStat[:empl_dismiss].to_i
    empl.vacancy_count = empl.vacancy_count||0
    empl.employee_manage_count = empl.employee_manage_count||0
    empl.employee_production_count = empl.employee_manage_count||0
    empl.k_dismiss = responseStat[:empl_dismiss].to_f/responseStat[:empl_count].to_i
    empl.k_complect = empl.k_complect||0
    empl.manager_avg_salary = responseStat[:aup_salary].to_i/responseStat[:aup_empl_count].to_i
    empl.AUP_count = responseStat[:aup_empl_count].to_i

    empl.save

  end

  def self.recalculateManagersCount
    EmployeeStatsMonths.where(month: Date.today-1.year..Date.today.at_end_of_month).each do |monthStat|
      productEmplCount = EmployeeStatsDepartments.where(month: monthStat.month, dep_type: 'p').sum(:employee_count)
      monthStat.employee_manage_count=monthStat.employee_count-productEmplCount
      monthStat.employee_production_count=productEmplCount
      monthStat.save
    end
  end
end
