class ObjectPrepare < ActiveRecord::Base
  ObjectPrepare.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfoEngeneerPrepare'
  self.primary_key = 'ObjectId'

  has_one :obj, foreign_key: 'ObjectId'

  alias_attribute 'destroy_net_compensation_document', '1_1'
  alias_attribute 'destroy_net_compensation_payed', '1_2'
  alias_attribute 'destroy_net_work_complete', '1_3'

  alias_attribute 'replace_engineer_compensation_document', '8_26'
  alias_attribute 'replace_engineer_compensation_payed', '8_27'
  alias_attribute 'replace_engineer_work_complete', '8_28'

  alias_attribute 'electro_techo_dogovor', '2_4'
  alias_attribute 'electro_build_percent', '2_5'
  alias_attribute 'electro_techo_act', '2_7'
  alias_attribute 'electro_techo_complete', '2_8'

  alias_attribute 'warm_get_RD', '3_9'
  alias_attribute 'warm_build_net_percent', '3_10'
  alias_attribute 'warm_installation_ITP_percent', '3_11'
  alias_attribute 'warm_temporary_document', '3_12'
  alias_attribute 'warm_complete', '3_13'

  alias_attribute 'water_get_RD', '4_14'
  alias_attribute 'water_build_net_percent', '4_15'
  alias_attribute 'water_act_get', '4_16'

  alias_attribute 'sewage_get_RD', '4_14'
  alias_attribute 'sewage_build_net_percent', '4_15'
  alias_attribute 'sewage_act_get', '4_16'

  alias_attribute 'drain_get_RD', '4_14'
  alias_attribute 'drain_build_net_percent', '4_15'
  alias_attribute 'drain_act_get', '4_16'

  alias_attribute 'link_get_RD', '4_14'
  alias_attribute 'link_build_net_percent', '4_15'
  alias_attribute 'link_act_get', '4_16'

end
