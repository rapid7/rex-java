# -*- coding: binary -*-

require 'rex/java/serialization'

###
# Metamodel based Java serializer/deserializer
#
# Using this module Java serialized streams can be created
# conveniently using APIs that resemble their Java counterparts.
#
# The object graph to be serialized is modeled in ruby objects,
# which is transformed using a metamodel of abstract class 
# specifications. This specification can be generated from the
# actual Java classes and persisted in a JSON file.
# Custom serialization handlers need to be reimplemented in
# ruby code (see metamodel/handlers).
#
# Some basic deserialization support is provided as well.
###
module Rex
  module Java
    module Serialization
      module Metamodel

        autoload :ObjectInputStream, 'rex/java/serialization/metamodel/input'
        autoload :ObjectOutputStream, 'rex/java/serialization/metamodel/output'
        autoload :Registry, 'rex/java/serialization/metamodel/registry'

        autoload :JavaPrimitive, 'rex/java/serialization/metamodel/types'
        autoload :JavaBoolean, 'rex/java/serialization/metamodel/types'
        autoload :JavaByte, 'rex/java/serialization/metamodel/types'
        autoload :JavaShort, 'rex/java/serialization/metamodel/types'
        autoload :JavaChar, 'rex/java/serialization/metamodel/types'
        autoload :JavaInteger, 'rex/java/serialization/metamodel/types'
        autoload :JavaLong, 'rex/java/serialization/metamodel/types'
        autoload :JavaFloat, 'rex/java/serialization/metamodel/types'
        autoload :JavaDouble, 'rex/java/serialization/metamodel/types'


        autoload :JavaObject, 'rex/java/serialization/metamodel/types'
        autoload :JavaCustomObject, 'rex/java/serialization/metamodel/types'
        autoload :JavaProxy, 'rex/java/serialization/metamodel/types'
        autoload :JavaClass, 'rex/java/serialization/metamodel/types'
        autoload :ObjectStreamClass, 'rex/java/serialization/metamodel/types'
        autoload :JavaArray, 'rex/java/serialization/metamodel/types'
        autoload :JavaEnum, 'rex/java/serialization/metamodel/types'

        class DeserializeException < Rex::Java::Serialization::DecodeError
          def inititialize(ex)
            @ex = ex
          end
        end

        class ClassNotFoundError < RuntimeError
        end
      end
    end
  end
end

