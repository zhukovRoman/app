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
    @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
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
      #@plotXAxis.push(stat.month.strftime('%b'))
      @plotXAxis.push(@standalone_month_names[stat.month.month])
      @plotDataSalary.push(stat.salary)
      @plotDataBonus.push(stat.bonus)
      @plotDataTax.push(stat.tax)
      @plotDataAvgSalary.push(stat.avg_salary.round 1)

      @plotDataEmployeeAdd.push(stat.employee_adds)
      @plotDataEmployeeCount.push(stat.employee_count)
      @plotDataEmployeeDismiss.push(stat.employee_dismiss)
      @plotDataVacancyCount.push(stat.vacancy_count)

      @plotDatakNeuk.push(stat.k_complect.round 4)
      @plotDatakTek.push(stat.k_dismiss.round 4)

      @plotDataManageCount.push((100*stat.employee_manage_count.to_f/stat.employee_count).round 1)
      @plotDataProdCount.push((100*stat.employee_production_count.to_f/stat.employee_count).round 1)

      @plotDataManageBonus.push(stat.bonus_manage)
      @plotDataManageSalary.push(stat.salary_manage)
      @plotDataManageTax.push(stat.tax_manage)
      @plotDataManageAvg.push(stat.avg_salary_manage.round 0)
      @plotDataAUPCount.push(stat.AUP_count)
    end

    #departments stats
    @plotXAxisDep = Array.new
    @plotDataDepEmployeeStats = Hash.new
    @plotDataDepEmployeeStats['vacancy'] = (Array.new)
    @plotDataDepEmployeeStats['employee_count'] = (Array.new)

    EmployeeStatsDepartments.where(month: (Date.current-1.month).at_beginning_of_month..(Date.current-1.month).at_end_of_month).each do |s|
      dep = Department.find(s.department_id)
      @plotXAxisDep.push(dep.name)

      info2 = Hash.new
      info2['y']=s.employee_count
      info2['manager']=s.manager
      @plotDataDepEmployeeStats['employee_count'].push(info2)

      info = Hash.new
      info['y']=s.vacancy_count
      info['manager']=s.manager
      @plotDataDepEmployeeStats['vacancy'].push(info)

      @drilldownData = EmployeeStatsDepartments.get_data_for_drilldown
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
    ["01", "02", "03", "04", "05"].each do |m|
      EmployeeStatsMonths.calculate_stat(Date.parse("2014-#{m}-05"))
      EmployeeStatsDepartments.calculate_stat(Date.parse("2014-#{m}-05"))
    end
      render plain: "ок"
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
    path = "salary_05_2014.xml"
    if !File.file?(path)
      render plain: "file not found!"
      return
    else
      f = File.open(rename_XML(path))
      xml = Nokogiri::XML(f)
      date = Date
      xml.xpath("//data/month").each do |m|
        month = m.attribute('number').inner_text()
        year = m.attribute('year').inner_text()
        date = Date.parse("#{year}-#{month}-05")
        puts date
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
