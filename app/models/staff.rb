class Staff

  @hiredCount
  @firedCount
  @underStaffing
  @turnover
  @bossTaxes
  @bossBonuses
  @bossSalary
  @bossAverageSalary
  @bossCount
  @departments
  @taxes
  @bonuses
  @salary
  @averageSalary
  @employeeCount
  @vacancyCount
  @departmentHead


  def initialize
    self.departments
    self.taxes
    self.bonuses
    self.salary
    self.averageSalary
    self.employeeCount
    self.vacancyCount
    self.departmentHead
    self.hiredCount
    self.firedCount
    self.underStaffing
    self.turnover
    self.bossTaxes
    self.bossBonuses
    self.bossSalary
    self.bossAverageSalary
    self.bossCount
  end

  def departments
    @departments = EmployeeStatsDepartments.select(:dep_name).distinct.each_with_index do |d, i|
      d.id = i+1
    end
  end

  def taxes
    @taxes = Array.new
    EmployeeStatsDepartments.where(month: Date.current-1.year..Date.current).each do |d|
      dep_id = @departments.find_index {|item| item.dep_name == d.dep_name}
      @taxes.push ({date: d.month.to_time.to_i, count: d.tax, department_id: dep_id+1})
    end
  end

  def bonuses
    @bonuses = Array.new
    EmployeeStatsDepartments.where(month: Date.current-1.year..Date.current).each do |d|
      dep_id = @departments.find_index {|item| item.dep_name == d.dep_name}
      @bonuses.push ({date: d.month.to_time.to_i, count: d.bonus, department_id: dep_id+1})
    end
  end

  def salary
    @salary = Array.new
    EmployeeStatsDepartments.where(month: Date.current-1.year..Date.current).each do |d|
      dep_id = @departments.find_index {|item| item.dep_name == d.dep_name}
      @salary.push ({date: d.month.to_time.to_i, count: d.salary, department_id: dep_id+1})
    end
  end

  def averageSalary
    @averageSalary = Array.new
    EmployeeStatsDepartments.where(month: Date.current-1.year..Date.current).each do |d|
      dep_id = @departments.find_index {|item| item.dep_name == d.dep_name}
      @averageSalary.push ({date: d.month.to_time.to_i, count: d.avg_salary, department_id: dep_id+1})
    end
  end

  def employeeCount
    @employeeCount = Array.new
    EmployeeStatsDepartments.where(month: Date.current-1.year..Date.current).each do |d|
      dep_id = @departments.find_index {|item| item.dep_name == d.dep_name}
      @employeeCount.push ({date: d.month.to_time.to_i, count: d.employee_count, department_id: dep_id+1})
    end
  end

  def vacancyCount
    @vacancyCount = Array.new
    EmployeeStatsDepartments.where(month: Date.current-1.year..Date.current).each do |d|
      dep_id = @departments.find_index {|item| item.dep_name == d.dep_name}
      @vacancyCount.push ({date: d.month.to_time.to_i, count: d.vacancy_count, department_id: dep_id+1})
    end
  end

  def departmentHead
    @departmentHead = Array.new
    EmployeeStatsDepartments.where(month: Date.current-1.month..Date.current).each do |d|
      dep_id = @departments.find_index {|item| item.dep_name == d.dep_name}
      @departmentHead.push ({date: d.month.to_time.to_i, name: d.manager, department_id: dep_id+1})
    end
  end

  def hiredCount
    @hiredCount = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @hiredCount.push ({date: s.month.to_time.to_i, count:s.employee_adds})
    end
    @hiredCount
  end

  def firedCount
    @firedCount = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @firedCount.push ({date: s.month.to_time.to_i, count:s.employee_dismiss})
    end
    @firedCount
  end

  def underStaffing
    @underStaffing = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @underStaffing.push ({date: s.month.to_time.to_i, count:s.k_complect})
    end
    @underStaffing
  end

  def turnover
    @turnover = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @turnover.push ({date: s.month.to_time.to_i, count:s.k_dismiss})
    end
    @turnover
  end

  def bossTaxes
    @bossTaxes = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @bossTaxes.push ({date: s.month.to_time.to_i, count:s.tax_manage})
    end
    @bossTaxes
  end

  def bossBonuses
    @bossBonuses = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @bossBonuses.push ({date: s.month.to_time.to_i, count:s.bonus_manage})
    end
    @bossBonuses
  end

  def bossSalary
    @bossSalary = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @bossSalary.push ({date: s.month.to_time.to_i, count:s.salary_manage})
    end
    @bossSalary
  end

  def bossAverageSalary
    @bossAverageSalary = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @bossAverageSalary.push ({date: s.month.to_time.to_i, count:s.avg_salary_manage})
    end
    @bossAverageSalary
  end

  def bossCount
    @bossCount = Array.new
    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
      @bossCount.push ({date: s.month.to_time.to_i, count:s.AUP_count})
    end
    @bossCount
  end
end