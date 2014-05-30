class EmployeeController < ApplicationController
  @@partName = "ГП УГС - Кадры"


  def vacancies

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
        month = m.attribute('number').to_s
        year = m.attribute('year').to_s
        date = Date.parse("#{year}-#{month}-05")
      end
      xml.xpath("//data/employees/employee").each do |node|
        empoloyee = Employee.find_by tab_number: node.attribute('id').to_s
        if empoloyee!=nil
          empoloyee.salaries.create(salary: node.attribute('salary').to_s.to_f, bonus: node.attribute('bonus').to_s.to_f,
                                    tax: node.attribute('tax').to_s.to_f, salary_date: date)
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
      f = File.open(path)
      xml = Nokogiri::XML(f)
      xml.xpath("//employee").each do |node|
        type = node.attribute('type').to_s
        date = Date.parse(node.attribute('date').to_s)
        if type == "Увольнение"
          empl = Employee.find_by tab_number: node.attribute('id').to_s
          if empl!=nil
            #persFlow = PersonalFlow.create(operation_type: type,
            #                               old_post: empl.post,
            #                               flow_date: date,
            #                               employee: empl,
            #                               old_department_id: empl.department.id)
            puts "УВОЛИТЬ #{empl.attributes}"
            #empl.destroy
          end
        end
        if type == "Прием на работу"
          dep = Department.find(node.parent.attribute('id').to_s.to_i)
          if dep!=nil
            empl = dep.employees.create(FIO: node.attribute('FIO').to_s, tab_number: node.attribute('id').to_s,
                                        stavka: 1, post: node.attribute('post').to_s)
            persFlow = PersonalFlow.create(operation_type: type,
                                           old_post: empl.post,
                                           flow_date: date,
                                           employee: empl,
                                           new_department_id: dep.id)
          end

          puts "ПРИНЯТЬ НА РАБОТУ #{333}"
        end
        if type == "Перевод"

          new_id = node.parent.attribute('id').to_s.to_i
          empl = Employee.find_by tab_number: node.attribute('id').to_s
          persFlow = PersonalFlow.create(operation_type: type,
                                         old_post: empl.post,
                                         new_post: node.attribute('post').to_s,
                                         flow_date: date,
                                         employee: empl,
                                         new_department_id: new_id,
                                         old_department_id: empl.department.id)
          empl.department_id = new_id
          empl.save
          puts "ПЕРВОД #{empl.attributes}"
        end
      end
      f.close
      render plain: "OK"
    end
  end
end
