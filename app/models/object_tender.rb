class ObjectTender < ActiveRecord::Base
  ObjectTender.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfoTenders'
  self.primary_key = 'TenderId'

  belongs_to :obj, foreign_key: 'ObjectId'
  has_one :organization, foreign_key: 'OrganizationId'

  alias_attribute 'object_id','ObjectId'
  alias_attribute 'status','TenderStatus'
  alias_attribute 'date_declaration','DataDeclaration'
  alias_attribute 'date_start','DataStart'
  alias_attribute 'date_finish','DataFinish'
  alias_attribute 'price_begin','TenderPriceBegin'
  alias_attribute 'price_end','TenderPriceEnd'
  alias_attribute 'percent_decline','TenderProcentDecline'
  alias_attribute 'price_m2_start','TenderPriceBeginOne'
  alias_attribute 'price_m2_end','TenderPriceEndOne'
  alias_attribute 'type','TenderSName'
  alias_attribute 'organization_id','TenderOrganization'
  alias_attribute 'bid_all','TenderQtyPresent'
  alias_attribute 'bid_accept','TenderQtyAccept'

  def self.frendly_date (date)
    date =  Date.parse(date.to_s(:db))
    return date.year.to_s+"-"+date.month.to_s+"-"+date.day.to_s
  end

end
