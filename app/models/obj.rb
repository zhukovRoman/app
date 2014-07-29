class Obj < ActiveRecord::Base
  Obj.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfo"
  self.primary_key = "ObjectId"

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
  alias_attribute "flors","ObjectAmountFloor" #
  alias_attribute "photo_path","ObjectPhotoPath" #

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
      return "";
    end
    parts = self.year_correct.to_s.split
    if parts==nil

    end
    return Date.parse(parts[0]).year

  end
end
