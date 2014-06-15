class EmployeeController < ApplicationController
  @@partName = "ГП УГС - Кадры"
  before_filter :authenticate_user!, :except => [:personalflowXmlParse, :salaryXmlParse, :personalInit]

  def vacancies
      @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
      if request.post? && params['departments'] != nil
        params['departments'].each do |k,v|
          dep = Department.find(k)
          dep.vacancy_count = v
          if !dep.valid?
            @error = ""
            dep.errors.full_messages.each do |msg|
              @error += msg
            end
            break
          else
            dep.save!
          end
        end
      end
      @departments = Department.where(parent_id:  nil)
  end

  def personalInit
    path = "personal.xml"
    if !File.file?(path)
      render plain: "file not found!"
      return
    else
      f = File.open(path)
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
    path = "salary.xml"
    if !File.file?(path)
      render plain: "file not found!"
      return
    else
      f = File.open(path)
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
    path = "personalFlow.xml"
    if !File.file?(path)
      render plain: "file not found!"
      return
    else
      count_all = 0
      count_new = 0
      count_del = 0
      f = File.open(path)
      xml = Nokogiri::XML(f)
      xml.xpath("//employee").each do |node|
        count_all = count_all +1
        type = node.attribute('type').inner_text()
        date = Date.parse(node.attribute('date').inner_text())
        if type == "Увольнение"
          count_del = count_del +1
          empl = Employee.find_by tab_number: node.attribute('id').inner_text()
          if empl!=nil
            persFlow = PersonalFlow.create(operation_type: type,
                                           old_post: empl.post,
                                           flow_date: date,
                                           employee: empl,
                                           old_department_id: empl.department.id)
            puts "УВОЛЕН СОТРУДНИК #{empl.attributes}"
            #empl.destroy
          else
            puts "НЕ НАЙДЕН СОТРУДНИК С ТАБЕЛЬНЫМ НОМЕРОМ #{node.attribute('id').inner_text()} ДЛЯ УВОЛЬНЕНИЯ"
          end
        end
        if type == "Прием на работу"
          count_new= count_new+1
          dep = Department.find_by out_number: node.parent.attribute('id').inner_text()
          if dep!=nil
            empl = dep.employees.create(FIO: node.attribute('FIO').inner_text(), tab_number: node.attribute('id').inner_text(),
                                        stavka: node.attribute('stavka').inner_text(), post: node.attribute('post').inner_text())
            persFlow = PersonalFlow.create(operation_type: type,
                                           new_post: empl.post,
                                           flow_date: date,
                                           employee: empl,
                                           new_department_id: dep.id)
            puts "ПРИНЯТЬ НА РАБОТУ #{empl.attributes}"
          else
            puts "НЕ НАЙДЕН ДЕПАРТАМЕНТ С ID = #{node.parent.attribute('id').inner_text()} В КОТОРЫЙ ПРИНЯТ СОТРУДНИК #{node.attribute('id').inner_text()}"
          end
        end
        if type == "Перемещение"
          new_id = node.parent.attribute('id').inner_text()
          empl = Employee.find_by tab_number: node.attribute('id').inner_text()
          if empl!=nil
            persFlow = PersonalFlow.create(operation_type: type,
                                           old_post: empl.post,
                                           new_post: node.attribute('post').inner_text(),
                                           flow_date: date,
                                           employee: empl,
                                           new_department_id: new_id,
                                           old_department_id: empl.department.id)
            empl.department_id = new_id
            empl.save
            puts "ПЕРВОД #{empl.attributes}"
          else
            puts "НЕ НАЙДЕН СОТРУДНИК С ТАБЕЛЬНЫМ НОМЕРОМ #{node.attribute('id').inner_text()} ДЛЯ ПЕРЕВОДА"
          end
        end
      end
      f.close
      render plain: "OK all = #{count_all} del = #{count_del} new = #{count_new}"
    end
  end
end
