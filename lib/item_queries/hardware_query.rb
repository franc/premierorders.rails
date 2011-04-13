require 'item_queries/item_query'

module ItemQueries
  class HardwareQuery < ItemQuery
    def initialize(&item_test)
      super(Monoid::ARRAY_APPEND)
      @item_test = item_test
    end

    def query_item_component(assoc, contexts)
      hardware = assoc.kind_of?(Items::ItemHardware) && (@item_test.nil? || @item_test.call(assoc.component)) ? [assoc] : []
      super(assoc, contexts) + hardware
    end
  end
end

