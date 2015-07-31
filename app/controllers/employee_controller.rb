class EmployeeController < ApplicationController

  #before_filter :authenticate_user!, :except => [:personalflowXmlParse, :salaryXmlParse, :personalInit, :calculate]
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
    #authorize! :index, self

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
      @plotDataSalary.push(stat.salary.round 0)
      @plotDataBonus.push(stat.bonus.round 0)
      @plotDataTax.push(stat.tax.round 0)
      @plotDataAvgSalary.push((stat.avg_salary.round 0))

      @plotDataEmployeeAdd.push(stat.employee_adds)
      @plotDataEmployeeCount.push(stat.employee_count)
      @plotDataEmployeeDismiss.push(stat.employee_dismiss)
      @plotDataVacancyCount.push(stat.vacancy_count)

      @plotDatakNeuk.push(((stat.k_complect*100).round 2))
      @plotDatakTek.push(((stat.k_dismiss*100).round 2))

      @plotDataManageCount.push((stat.employee_manage_count.to_f/1).round 1)
      @plotDataProdCount.push((stat.employee_production_count.to_f/1).round 1)

      @plotDataManageBonus.push(stat.bonus_manage.round 0)
      @plotDataManageSalary.push(stat.salary_manage.round 0)
      @plotDataManageTax.push(stat.tax_manage.round 0)
      @plotDataManageAvg.push(((stat.salary_manage/stat.AUP_count).round 0))
      @plotDataAUPCount.push(stat.AUP_count)
    end

    #departments stats
    @plotXAxisDep = Array.new
    @plotDataDepEmployeeStats = Hash.new
    @plotDataDepEmployeeStats['vacancy'] = (Array.new)
    @plotDataDepEmployeeStats['employee_count'] = (Array.new)

    #if(EmployeeStatsDepartments.where(month: (Date.current).at_beginning_of_month..(Date.current).at_end_of_month).count == 0)
    #  #EmployeeStatsDepartments.fillCurrentMonth()
    #end


    interval = (Date.current).at_beginning_of_month..(Date.current).at_end_of_month;
    if (Date.current.day<8 || EmployeeStatsDepartments.where(month: interval).count==0)
      #interval = (Date.current-2.month).at_beginning_of_month..(Date.current-2.month).at_end_of_month;
      last_date = EmployeeStatsMonths.order(month: :desc).take(1)
      last_date = last_date[0].month
      interval = last_date.at_beginning_of_month..(last_date).at_end_of_month;
    end


    EmployeeStatsDepartments.where(month: interval).where('employee_count>0').each do |s|
      # dep = Department.find(s.department_id)
      @plotXAxisDep.push(s.dep_name)

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

    @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]


  end

  def editmanagment
    if request.post? && params['dep'] != nil

      EmployeeStatsDepartments.update_all(:dep_type => 'u')

      params['dep'].each do |k,v|
        puts "dep #{k} val #{v}"
        EmployeeStatsDepartments.where(dep_name: k).update_all(:dep_type => 'p')
      end
      EmployeeStatsMonths.recalculateManagersCount
    end

    @departments = EmployeeStatsDepartments.select(:dep_name, :dep_type).group(:dep_name, :dep_type)
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
      date = Date.parse(@year.to_s+"-"+@month.to_s+"-15")
      @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
      if request.post? && params['vacancies'] != nil
        allCount = 0;
        params['vacancies'].each do |k,v|
          puts "vacancies #{k} count #{v}"
          stat = EmployeeStatsDepartments.find(k)
          stat.vacancy_count = v
          allCount += v.to_i;
          if !stat.valid?
            @error = ""
            stat.errors.full_messages.each do |msg|
              @error += msg
            end
            break
          else
            stat.save!
            statM = EmployeeStatsMonths.where(month: date.at_beginning_of_month..date.at_end_of_month).first
            statM.vacancy_count = allCount
            statM.k_complect = statM.vacancy_count.to_f/statM.employee_count
            statM.save
          end


        end
      end
      @departments = EmployeeStatsDepartments.where(month: date.at_beginning_of_month..date.at_end_of_month)
      # выборка данных для графика
      @plotXAxis = Array.new
      @plotData = Array.new
      EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |s|
        puts s.inspect
        @plotXAxis.push(@standalone_month_names[s.month.month])
        @plotData.push(s.vacancy_count)
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


  def getEmployeeStats
    require 'savon'
    if (params['year']==nil || params['month']==nil)
      render plain: 'wrong arguments'
      return
    end
    message = {year: params['year'], month: params['month']}
    client = Savon.client(wsdl: 'http://172.20.10.89/zarplata/ws/vigruzkazp.1cws?wsdl', basic_auth: ["web1c", "123"])

    response = client.call(:get_month_stat, message: message)

    EmployeeStatsMonths.saveStatsFromSOAP response.body[:get_month_stat_response][:return]
    EmployeeStatsDepartments.saveStatsFromSOAP response.body[:get_month_stat_response][:return][:departments][:department] ,
                                               response.body[:get_month_stat_response][:return][:year]+'-'+response.body[:get_month_stat_response][:return][:month]+'-15'
    render plain: 'ok'
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
    path = Employee.getReportsPath + "salary_#{m}_2015.xml"
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
    path = Employee.getReportsPath + "personalflow_#{m}_2015.xml"
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
                                     node.attribute('FIO').inner_text(),
                                     node.parent)
      end
    end
    render plain: "ok"
  end
end
