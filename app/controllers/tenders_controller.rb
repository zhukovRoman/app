class TendersController < ApplicationController
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Конкурсы"
  end

  def index
    authorize! :index, self
    require 'json'

    @result = Hash.new
    years = Array.new
    @result['prices_begin']=Hash.new
    @result['prices_end']=Hash.new
    @result['prices_percent']=Hash.new
    @result['one_end']=Hash.new
    @result['one_start']=Hash.new
    @result['count']=Hash.new

   ObjectTender.all.each do |t|
      date = Date.parse(t.date_start.to_s)
      if (!years.include? date.year)
        years.push(date.year)
      end
      @result['count'][date.year] = (@result['count'][date.year]||0) + 1
      @result['prices_begin'][date.year] = (@result['prices_begin'][date.year]||0) + (t.price_begin||0)
      @result['prices_end'][date.year] = (@result['prices_end'][date.year]||0) + (t.price_end||0)
      @result['one_end'][date.year] = (@result['one_end'][date.year]||0) + (t.price_m2_end||0)
      @result['one_start'][date.year] = (@result['one_start'][date.year]||0) + (t.price_m2_start||0)
      @result['prices_percent'][date.year] = (@result['prices_percent'][date.year]||0) + (t.percent_decline||0)

   end



    @result['years']=years
    @result['types_chart_data']=Array.new
    ObjectTender.group('TenderSName').sum(:price_end).each do |k, v|
      tmp = Array.new
      tmp.push (k)
      tmp.push((v/1000000).round)
      @result['types_chart_data'].push(tmp)
    end

    @result['types_chart_count_data']=Array.new
    ObjectTender.group('TenderSName').count(:object_id).each do |k, v|
      tmp = Array.new
      tmp.push (k)
      tmp.push(v.round)
      @result['types_chart_count_data'].push(tmp)
    end

    @result['qty'] = ObjectTender.get_qty_tenders_count
    @result['qty_sum'] = ObjectTender.get_qty_tenders_sum
    @result['qty_years'] = Array.new
    @result['qty_drilldowns'] = Hash.new
    ObjectTender.select('YEAR(DataFinish) as year').distinct.each do |y|
      @result['qty_years'].push y.year
      @result['qty_drilldowns'][y.year]=ObjectTender.get_qty_tenders_drilldown_by_year y.year

    end


    @result['uk_m2_price']=ObjectTender.uk_m2_price
    @result['gen_m2_price']=ObjectTender.gen_m2_price

    @tenders = Array.new
    ObjectTender.where('ObjectId IS NOT NULL').includes(:obj).each do |t|
      tender = Hash.new
      tender['status']=t.status
      tender['id']=t.id
      tender['year_finish']=t.date_finish.year
      tender['month_finish']=t.date_finish.month
      tender['type']=t.type
      tender['percent']=t.percent_decline||0
      tender['price_m2_end']=t.price_m2_end||0
      tender['price_m2_start']=t.price_m2_start||0
      tender['price_end']=t.price_end||0
      tender['price_start']=t.price_begin||0
      tender['bid_all']=t.bid_all||0
      tender['bid_accept']=t.bid_accept||0
      tender['bid_reject']=(t.bid_all||0)-(t.bid_accept||0)
      tender['uk_only']=t.isUkOnly
      tender['without_uk']=t.isWithoutUk

      if t.obj != nil
        tender['appointment']=t.obj.appointment
        tender['series']=(t.obj.seria=='ИНД') ? t.obj.seria : 'Сер'
        @tenders.push tender
      end

    end



    #@result[]
  end
end
