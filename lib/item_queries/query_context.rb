require 'fp'

class QueryContext
  def initialize(args = {})
    @data = args
  end

  def color 
    Option.new(@data[:color])
  end

  def units 
    Option.new(@args[:units])
  end

  def component_contexts 
    @data[:component_contexts] || []
  end

  def use_bulk_pricing?
    @use_bulk_pricing = @data[:bulk] == true
  end

  def left_merge(args = {})
    QueryContext.new(@data.merge{|k, v1, v2| v1.nil? ? v2 : v1})
  end
end
