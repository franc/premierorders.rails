require 'expressions'
require 'fp'

module ItemQueries
  class PropertySum < ItemQuery
    include Expressions

    def initialize(units, &prop)
      super(Monoid::OptionM.new(Semigroup::SUM))
      @prop = prop
      @units = units
    end

    def query_item(item)
      Option.new(@prop.call(item)).map{|w| term(w)}
    end

    def query_item_component(assoc, contexts)
      assoc.component.query(self, contexts).map{|expr| assoc.qty_expr(@units) * expr}
    end
  end
end


