class EmployeeController < ApplicationController

  before_filter :authenticate_user!, :except => [:personalflowXmlParse, :salaryXmlParse, :personalInit, :calculate]
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Кадры"
  end


  def rename_XML (path)
    #File.rename(path, path+".c")
    #return path+".c"
    return path
  end

  def index
    authorize! :index, self

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
      @plotDataSalary.push(stat.salary.round 2)
      @plotDataBonus.push(stat.bonus.round 2)
      @plotDataTax.push(stat.tax.round 2)
      @plotDataAvgSalary.push((stat.avg_salary.round 2))

      @plotDataEmployeeAdd.push(stat.employee_adds)
      @plotDataEmployeeCount.push(stat.employee_count)
      @plotDataEmployeeDismiss.push(stat.employee_dismiss)
      @plotDataVacancyCount.push(stat.vacancy_count)

      @plotDatakNeuk.push(((stat.k_complect*100).round 4))
      @plotDatakTek.push(((stat.k_dismiss*100).round 4))

      @plotDataManageCount.push((stat.employee_manage_count.to_f/1).round 1)
      @plotDataProdCount.push((stat.employee_production_count.to_f/1).round 1)

      @plotDataManageBonus.push(stat.bonus_manage.round 2)
      @plotDataManageSalary.push(stat.salary_manage.round 2)
      @plotDataManageTax.push(stat.tax_manage.round 2)
      @plotDataManageAvg.push((stat.avg_salary_manage.round 0))
      @plotDataAUPCount.push(stat.AUP_count)
    end

    #departments stats
    @plotXAxisDep = Array.new
    @plotDataDepEmployeeStats = Hash.new
    @plotDataDepEmployeeStats['vacancy'] = (Array.new)
    @plotDataDepEmployeeStats['employee_count'] = (Array.new)

    if(EmployeeStatsDepartments.where(month: (Date.current).at_beginning_of_month..(Date.current).at_end_of_month).count == 0)
      #EmployeeStatsDepartments.fillCurrentMonth()
    end


    interval = (Date.current-1.month).at_beginning_of_month..(Date.current-1.month).at_end_of_month;
    if (Date.current.day<8)
      interval = (Date.current-2.month).at_beginning_of_month..(Date.current-2.month).at_end_of_month;
    end

    EmployeeStatsDepartments.where(month: interval).each do |s|
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
    end
    @drilldownData = EmployeeStatsDepartments.get_data_for_drilldown
    @departmentsEmployeesMonthsCounts = EmployeeStatsDepartments.getMonthsEmployeesCounts

  end

  def editmanagment
    if request.post? && params['dep'] != nil

      Department.where(parent_id: nil).update_all(:department_type => 0)

      params['dep'].each do |k,v|
        puts "dep #{k} val #{v}"
        dep = Department.find(k)
        dep.department_type = 1
        dep.save!
      end

    end

    @departments = Department.where(parent_id: nil)

  end

  def vacancies
      authorize! :vacancies, self

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
    if params[:month]!=nil
      m = params[:month]
      EmployeeStatsMonths.calculate_stat(Date.parse("2014-#{m}-05"))
      EmployeeStatsDepartments.calculate_stat(Date.parse("2014-#{m}-05"))
      render plain: "ок"
    else
      render plain: "wrong month number"
    end

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
                                       stavka: employee.attribute('stavka').inner_text().sub(",", "."), post: employee.attribute('post').to_s)
        end
        node.xpath("./department").each do |dep|
          department = Department.create(name: dep.attribute('name').to_s, vacancy_count: 0,
                                         out_number: dep.attribute('id').to_s, parent: directorate)
          dep.xpath("./employee").each do |employee|
            puts employee.attribute('stavka').inner_text().sub(",", ".")
            department.employees.create(FIO: employee.attribute('FIO').to_s, tab_number: employee.attribute('id').to_s,
                                        stavka: employee.attribute('stavka').inner_text().sub(",", "."), post: employee.attribute('post').to_s)
          end
          dep.xpath("./sector").each do |sector|
            sector_obj = Department.create(name: sector.attribute('name').to_s, vacancy_count: 0,
                                           out_number: sector.attribute('id').to_s , parent: department)
            sector.xpath("./employee").each do |employee|
              sector_obj.employees.create(FIO: employee.attribute('FIO').to_s, tab_number: employee.attribute('id').to_s,
                                          stavka: employee.attribute('stavka').inner_text().sub(",", ".") , post: employee.attribute('post').to_s)
            end
          end
        end
      end
      f.close
      render plain: "OK"
    end
  end

  def salaryXMLChange
    render plain: Employee.find_by_FIO("test").attributes
  end

  def salaryXmlParse
    if params[:month]==nil
      render plain: "wrong month number"
      return
    end
    m =  params[:month]
    logger = Logger.new("#{Rails.root}/log/salary_#{Date.current.year}_#{Date.current.month}.log")
    path = Employee.getReportsPath + "salary_#{m}_2014.xml"
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
          empoloyee.salaries.create(salary: node.attribute('salary').inner_text().sub(",", "."),
                                    bonus: node.attribute('bonus').inner_text().sub(",", "."),
                                    insurance: node.attribute('insurance').inner_text().sub(",", "."),
                                    NDFL: node.attribute('NDFL').inner_text().sub(",", "."),
                                    retention: node.attribute('retention').inner_text().sub(",", "."),
                                    salary_date: date)
        else
          dep = Department.find_by_out_number (node.attribute('unit').inner_text())
          if dep != nil
            logger.warn("НЕ НАЙДЕН СОТРУДНИК С ТАБЕЛЬНЫМ НОМЕРОМ #{node.attribute('id').inner_text()} ДЛЯ НАЧИСЛЕНИЯ ЗП (создадим пустого)")
            emp = Employee.create(department_id: dep.id, tab_number: node.attribute('id').inner_text(), FIO: "empty")
            emp.salaries.create(salary: node.attribute('salary').inner_text().sub(",", "."),
                                 bonus: node.attribute('bonus').inner_text().sub(",", "."),
                                 insurance: node.attribute('insurance').inner_text().sub(",", "."),
                                 NDFL: node.attribute('NDFL').inner_text().sub(",", "."),
                                 retention: node.attribute('retention').inner_text().sub(",", "."),
                                 salary_date: date)
          else
            logger.warn("НЕ НАЙДЕН СОТРУДНИК И ЕГО ПОДРАЗДЕЛЕНИЕ С ТАБЕЛЬНЫМ НОМЕРОМ #{node.attribute('id').inner_text()} ДЛЯ НАЧИСЛЕНИЯ ЗП")
          end
        end
      end
      f.close
      render plain: "OK"
    end
  end

  def personalflowXmlParse
    if params[:month]==nil
      render plain: "wrong month number"
      return
    end
    m = params[:month]
    path = Employee.getReportsPath + "personalflow_#{m}_2014.xml"
    puts path
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
                                 node.attribute('stavka').inner_text().sub(",", "."),
                                 node.parent.attribute('id').inner_text(),
                                 node.attribute('date').inner_text(),
                                 node.parent)
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
                                     node.attribute('stavka').inner_text().sub(",", "."),
                                     node.attribute('date').inner_text(),
                                     node.parent.attribute('id').inner_text(),
                                     node.attribute('post').inner_text(),
                                     node.parent)
      end
    end
    render plain: "ok"
  end
end
