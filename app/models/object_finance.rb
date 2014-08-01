class ObjectFinance < ActiveRecord::Base
  ObjectFinance.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfoFinance"
  self.primary_key = "ObjectId"

  has_one :obj, foreign_key: "ObjectId"

  alias_attribute "appointment_type","ObjectAppointmentType"
  alias_attribute "current_year_payd","PayTekYear"
  alias_attribute "year_limit", "TitulTekYear"
  alias_attribute "complete_work", "WorkVipilneno"

  def self.getAllAppointmentType
     return ObjectFinance.select("appointment_type").distinct
  end

  def incomplete_work
    return self.current_year_payd||0-self.complete_work||0
  end
end
