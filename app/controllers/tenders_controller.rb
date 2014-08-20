class TendersController < ApplicationController
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
      tmp.push(v.round)
      @result['types_chart_data'].push(tmp)
    end


    #@result[]
  end
end
