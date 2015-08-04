namespace :employee do
  task update_employees_stats: :environment do
    puts 'update employees…'
    Rake::Task['employee:get_stats_current_month'].invoke
    Rake::Task['employee:get_stats_prev_month'].invoke
    puts 'update employees complete'
  end

  task get_stats_current_month: :environment do
    require 'savon'
    year = Date.current.year.to_s
    month = Date.current.month.to_s
    message = {year: year, month: month}
    client = Savon.client(wsdl: 'http://172.20.10.89/zarplata/ws/vigruzkazp.1cws?wsdl', basic_auth: ["web1c", "123"])

    response = client.call(:get_month_stat, message: message)

    EmployeeStatsMonths.saveStatsFromSOAP response.body[:get_month_stat_response][:return]
    EmployeeStatsDepartments.saveStatsFromSOAP response.body[:get_month_stat_response][:return][:departments][:department] ,
                                               response.body[:get_month_stat_response][:return][:year]+'-'+response.body[:get_month_stat_response][:return][:month]+'-15'
  end
  task get_stats_prev_month: :environment do
    require 'savon'
    year = (Date.current-1.month).year.to_s
    month = (Date.current-1.month).month.to_s
    message = {year: year, month: month}
    client = Savon.client(wsdl: 'http://172.20.10.89/zarplata/ws/vigruzkazp.1cws?wsdl', basic_auth: ["web1c", "123"])

    response = client.call(:get_month_stat, message: message)

    EmployeeStatsMonths.saveStatsFromSOAP response.body[:get_month_stat_response][:return]
    EmployeeStatsDepartments.saveStatsFromSOAP response.body[:get_month_stat_response][:return][:departments][:department] ,
                                               response.body[:get_month_stat_response][:return][:year]+'-'+response.body[:get_month_stat_response][:return][:month]+'-15'
  end
end
