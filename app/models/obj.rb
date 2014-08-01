class Obj < ActiveRecord::Base
  Obj.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfo"
  self.primary_key = "ObjectId"

  has_one :object_finance, foreign_key: "ObjectId"

  alias_attribute "series_name", "ObjectSerialName" #
  alias_attribute "region_name", "ObjectRegionName" #
  alias_attribute "general_builder", "OrganizationGenBuilder" #
  alias_attribute "techinikal_customer", "OrganizationTehZakaz" #
  alias_attribute "projector","OrganizationProjector" #проектировщик
  alias_attribute "managers_company","OrganizationUK" #управляющая компания
  alias_attribute "appointment","ObjectAppointmentName" #
  alias_attribute "budget","ObjectFinanceBudget" #
  alias_attribute "id","ObjectId" #
  alias_attribute "is_archive","ObjectArchve" #
  alias_attribute "adress","ObjectAdress" #
  alias_attribute "name","ObjectName" #
  alias_attribute "year_plan","ObjectEnterYearPlan" #
  alias_attribute "year_correct","ObjectEnterYearCorrect" #
  alias_attribute "year_DS","ObjectEnterYear" #
  alias_attribute "power","ObjectPower" #
  alias_attribute "manager","ObjectManager" #
  alias_attribute "date_of_enter","ObjectDataEnter" #
  alias_attribute "power_measure","PowerEdIzm" #
  alias_attribute "status_name","ObjectStatusName" #
  alias_attribute "floors","ObjectAmountFloor" #
  alias_attribute "photo_path","ObjectPhotoPath" #
  alias_attribute "dataGPZU","DataGPZU" #
  alias_attribute "plan_dataGPZU","DataPlanGPZU" #
  alias_attribute "data_razresh_str", "DataRazreshStr"
  alias_attribute "plan_data_razresh_str", "DataPlanRazreshStr"
  alias_attribute "data_MGE", "DataMGE"
  alias_attribute "plan_data_MGE","DataPlanMGE"

  def self.get_years_enters_plan
    return Obj.group("ObjectEnterYearPlan").order(:year_plan).count(:id)
  end

  def self.get_years_enters_fact
    return Obj.group("YEAR(ObjectEnterYearCorrect)").order("YEAR(ObjectEnterYearCorrect)").count(:id)
  end

  def getLatLng
    require 'net/http'
    require 'json'

    uri = URI("http://maps.google.com/maps/api/geocode/json?address=#{self.adress}&sensor=false")
    geo_response = Net::HTTP.get(uri) # => String
    resp = JSON.parse(geo_response)
    puts resp;
    return "[1,1]";
  end

  def getYearCorrect

    if self.year_correct == nil
      return "----";
    end
    parts = self.year_correct.to_s.split
    if parts==nil

    end
    return Date.parse(parts[0]).year

  end

  def getGPZUStatus
    if self.plan_dataGPZU == nil
      return "Без ГПЗУ"
    end
    if self.dataGPZU != nil
      return "Получено"
    end
    if self.dataGPZU == nil && Date.parse(plan_dataGPZU) >= Date.current
      return "Без ГПЗУ"
    end
    if self.dataGPZU == nil && Date.parse(plan_dataGPZU) < Date.current
      return "Просрочено"
    end
  end

  def getMGEStatus
    if self.plan_data_MGE == nil
      return "Без экспертизы"
    end
    if self.data_MGE != nil
      return "Получено"
    end
    if self.data_MGE == nil && Date.parse(plan_data_MGE) >= Date.current
      return "Без экспертизы"
    end
    if self.data_MGE == nil && Date.parse(plan_data_MGE) < Date.current
      return "Просрочено"
    end
  end

  def getRazreshStatus
    if self.plan_data_razresh_str == nil
      return "Без разрешения"
    end
    if self.data_razresh_str != nil
      return "Получено"
    end
    if self.data_razresh_str == nil && Date.parse(plan_data_razresh_str) >= Date.current
      return "Без разрешения"
    end
    if self.data_razresh_str == nil && Date.parse(plan_data_razresh_str) < Date.current
      return "Просрочено"
    end
  end

  def self.getAllDistricts
    return Obj.where(is_archive: 0, ).select("ObjectRegionName").distinct
  end

  # todo
  # сделать выбор правильного года
  def self.getAllEnterYears
    res = Array.new
    Obj.where(is_archive: 0).select("ObjectEnterYearCorrect").each do |o|
      if (!res.include?(o.getYearCorrect.to_s))
        res.push(o.getYearCorrect.to_s)
      end
    end
    return res.sort
  end

  def self.notArchive
    return Obj.where(is_archive: 0).includes(:object_finance)
  end

  def getFinanceObj
    return ObjectFinance.find(self.id)
  end

  def self.overdueObjects
    return Obj.where('ObjectArchve = 0 AND DataPlanGPZU < ?', Date.current)
  end
end
