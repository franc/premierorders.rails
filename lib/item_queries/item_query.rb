module ItemQueries
  class ItemQuery
    attr_reader :monoid

    def initialize(monoid)
      @monoid = monoid
    end

    def selected_component_associations(item, context) 
      if context.component_contexts.empty?
        item.item_components
      else
        # Find each component association where the context list for that association
        # contains at least one of the contexts specified to this method.
        item.item_components.select do |comp|
          (comp.contexts - context.component_contexts).size < comp.contexts.size
        end
      end
    end

    def traverse_item(item, context)
      item_data = query_item(item)

      property_data = item.properties.inject(item_data) do |v, prop|
        @monoid.append(v, query_property(prop))
      end

      selected_component_associations(item, context).inject(property_data) do |v, assoc|
        @monoid.append(v, assoc.query(self, context))
      end
    end

    def traverse_item_component(assoc, context)
      component_data = query_item_component(assoc, context)
      assoc.properties.inject(component_data) do |v, prop|
        @monoid.append(v, query_property(prop))
      end
    end

    def query_item(item)
      @monoid.zero 
    end

    def query_item_component(assoc, context)
      assoc.component.query(self, context)
    end

    def query_property(property)
      @monoid.zero 
    end
  end
end
