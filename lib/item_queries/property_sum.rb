require 'expressions'
require 'fp'

module ItemQueries
  class PropertySum < ItemQuery
    include Expressions

    def initialize(&prop)
      super(Monoid::OptionM.new(Semigroup::SUM))
      @prop = prop
    end

    def query_item(item)
      Option.new(@prop.call(item)).map{|w| term(w)}
    end

    def query_item_component(assoc, query_context)
      assoc.component.query(self, query_context).map{|expr| assoc.qty_expr(query_context) * expr}
    end
  end
end


