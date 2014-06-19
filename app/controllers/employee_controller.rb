class EmployeeController < ApplicationController

  before_filter :authenticate_user!, :except => [:personalflowXmlParse, :salaryXmlParse, :personalInit]
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Кадры"
  end

  def rename_XML (path)
    #File.rename(path, "_"+path)
    #return "_"+path
    return path
  end

  def index
    @plotXAxis = Array.new
    @plotDataSalary = Array.new
    @plotDataBonus = Array.new
    @plotDataTax = Array.new
    @plotDataAvgSalary = Array.new

    @plotDataEmployeeCount = Array.new
    @plotDataEmployeeDismiss = Array.new
    @plotDataEmployeeAdd = Array.new
    @plotDataVacancyCount = Array.new

    @plotDatakTek = Array.new
    @plotDatakNeuk = Array.new

    @plotDataManageCount = Array.new
    @plotDataProdCount = Array.new

    @plotDataManageSalary = Array.new
    @plotDataManageTax = Array.new
    @plotDataManageBonus = Array.new
    @plotDataManageAvg = Array.new
    @plotDataAUPCount = Array.new

    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |stat|
      @plotXAxis.push(stat.month.strftime("%b"))
      @plotDataSalary.push(stat.salary)
      @plotDataBonus.push(stat.bonus)
      @plotDataTax.push(stat.tax)
      @plotDataAvgSalary.push(stat.avg_salary)

      @plotDataEmployeeAdd.push(stat.employee_adds)
      @plotDataEmployeeCount.push(stat.employee_count)
      @plotDataEmployeeDismiss.push(stat.employee_dismiss)
      @plotDataVacancyCount.push(stat.vacancy_count)

      @plotDatakNeuk.push(stat.k_complect)
      @plotDatakTek.push(stat.k_dismiss)

      @plotDataManageCount.push(100*stat.employee_manage_count.to_f/stat.employee_count)
      @plotDataProdCount.push(100*stat.employee_production_count.to_f/stat.employee_count)

      @plotDataManageBonus.push(stat.bonus_manage)
      @plotDataManageSalary.push(stat.salary_manage)
      @plotDataManageTax.push(stat.tax_manage)
      @plotDataManageAvg.push(25000)
      @plotDataAUPCount.push(20)

    end

  end

  def editmanagment

  end

  def vacancies
      @month = params[:month]
      if (@month== nil)
        @month = Date.current.month
      end
      @year = params[:year]
      if (@year== nil)
        @year = Date.current.year
      end
      @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
      if request.post? && params['vacancies'] != nil
        params['vacancies'].each do |k,v|
          puts "vacancies #{k} count #{v}"
          vac = Vacancies.find(k)
          vac.count = v
          if !vac.valid?
            @error = ""
            vac.errors.full_messages.each do |msg|
              @error += msg
            end
            break
          else
            vac.save!
          end
        end
      end
      #@departments = Department.where(parent_id:  nil)
      date = Date.parse(@year.to_s+"-"+@month.to_s+"-28")
      Department.where(parent_id:  nil).each do |dep|
        vac = dep.vacancies.where(for_date: date.at_beginning_of_month..date).take
        if (vac == nil)
          dep.vacancies.create(count: 0, for_date: date.at_beginning_of_month+14.day)
        end
      end
      @vacancies = Vacancies.where(for_date: date.at_beginning_of_month..date)
      # выборка данных для графика
      @plotXAxis = Array.new
      @plotData = Array.new
      Vacancies.where(for_date: Date.current-1.year..Date.current).group("for_date").sum("count").each do |k, v|
        @plotXAxis.push(@standalone_month_names[k.month])
        @plotData.push(v)
      end
  end

  def calculate
    stat = EmployeeStatsMonths.calculate_stat(Date.parse("2014-05-05"))
    EmployeeStatsDepartments.calculate_stat(Date.parse("2014-05-05"))
    render plain: "#{stat.attributes}"
  end


  #################
  #   Разбор XML  #
  #################
  def personalInit
    path = "personal.xml"
    if !File.file?(path)
      render plain: "file not found!"
      return
    else
      #path = rename_XML(path)
      f = File.open(rename_XML(path))
      xml = Nokogiri::XML(f)
      xml.xpath("//data/directorate").each do |node|
        directorate = Department.create(name: node.attribute('name').to_s , vacancy_count: 0,
                                        out_number: node.attribute('id').inner_text())
        node.xpath("./employee").each do |employee|
          directorate.employees.create(FIO: employee.attribute('FIO').to_s, tab_number: employee.attribute('id').to_s,
                                       stavka: employee.attribute('stavka').inner_text(), post: employee.attribute('post').to_s)
        end
        node.xpath("./department").each do |dep|
          department = Department.create(name: dep.attribute('name').to_s, vacancy_count: 0,
                                         out_number: dep.attribute('id').to_s, parent: directorate)
          dep.xpath("./employee").each do |employee|
            department.employees.create(FIO: employee.attribute('FIO').to_s, tab_number: employee.attribute('id').to_s,
                                        stavka: employee.attribute('stavka').inner_text(), post: employee.attribute('post').to_s)
          end
          dep.xpath("./sector").each do |sector|
            sector_obj = Department.create(name: sector.attribute('name').to_s, vacancy_count: 0,
                                           out_number: sector.attribute('id').to_s , parent: department)
            sector.xpath("./employee").each do |employee|
              sector_obj.employees.create(FIO: employee.attribute('FIO').to_s, tab_number: employee.attribute('id').to_s,
                                          stavka: employee.attribute('stavka').inner_text(), post: employee.attribute('post').to_s)
            end
          end
        end
      end
      f.close
      render plain: "OK"
    end
  end

  def salaryXmlParse
    path = "salary_0x_2014.xml"
    if !File.file?(path)
      render plain: "file not found!"
      return
    else
      #path = rename_XML(path)
      f = File.open(rename_XML(path))
      xml = Nokogiri::XML(f)
      date = Date
      xml.xpath("//data/month").each do |m|
        month = m.attribute('number').inner_text()
        year = m.attribute('year').inner_text()
        date = Date.parse("#{year}-#{month}-05")
      end
      xml.xpath("//data/employees/employee").each do |node|
        empoloyee = Employee.find_by tab_number: node.attribute('id').inner_text()
        if empoloyee!=nil
          empoloyee.salaries.create(salary: node.attribute('salary').inner_text(), bonus: node.attribute('bonus').inner_text(),
                                    insurance: node.attribute('insurance').inner_text(),
                                    NDFL: node.attribute('NDFL').inner_text(),
                                    retention: node.attribute('retention').inner_text(),
                                    salary_date: date)
        else
          puts "НЕ НАЙДЕН СОТРУДНИК С ТАБЕЛЬНЫМ НОМЕРОМ #{node.attribute('id').inner_text()} ДЛЯ НАЧИСЛЕНИЯ ЗП"
        end
      end
      f.close
      render plain: "OK"
    end
  end

  def personalflowXmlParse
    path = "personalflow_0X_2014.xml"
    if !File.file?(path)
      render plain: "file not found!"
      return
    else
      #path = rename_XML(path)
      f = File.open(rename_XML(path))
      xml = Nokogiri::XML(f)
      xml.xpath("//employee[@type='#{Employee::FLOWADDTYPE}']").each do |node|
          Employee.add_employee(node.attribute('FIO').inner_text(),
                                 node.attribute('id').inner_text(),
                                 node.attribute('post').inner_text(),
                                 node.attribute('stavka').inner_text(),
                                 node.parent.attribute('id').inner_text(),
                                 node.attribute('date').inner_text())
      end
      xml.xpath("//employee[@type='#{Employee::FLOWDISMISSTYPE}']").each do |node|
          Employee.dismiss_employee(node.attribute('id').inner_text(),
                                    node.attribute('date').inner_text(),
                                    node.attribute('post').inner_text(),
                                    node.parent.attribute('id').inner_text())
      end
      xml.xpath("//employee[@type='#{Employee::FLOWTRANSFERTYPE}']").each do |node|
          Employee.transfer_employee(node.attribute('id').inner_text(),
                                     node.attribute('post').inner_text(),
                                     node.attribute('stavka').inner_text(),
                                     node.attribute('date').inner_text(),
                                     node.parent.attribute('id').inner_text(),
                                     node.attribute('post').inner_text())
      end
    end
    render plain: "ok"
  end
end
