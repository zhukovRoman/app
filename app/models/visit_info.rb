class VisitInfo < ActiveRecord::Base
  VisitInfo.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfoVisit"
  self.primary_key = "Sort2"

  has_one :obj, foreign_key: "ObjectId"

  alias_attribute "object_id", "ObjectId"
  alias_attribute "parametr_name","Parametr"
  alias_attribute "percent", "Procent"
  alias_attribute "comment", "Comment"
  alias_attribute "sort1","Sort1"
  alias_attribute "sort2","Sort2"
  alias_attribute "max_data", "MaxData"

  def get_parametr_name
    return self.parametr_name.gsub(' ','&nbsp;')
  end
end
