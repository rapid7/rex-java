# -*- coding: binary -*-

module Rex
  module Java
    module Serialization
      module Metamodel
        class JavaPrimitive
          attr_accessor :value
          def initialize(value)
            @value = value
          end
        end

        class JavaBoolean < JavaPrimitive
        end

        class JavaByte < JavaPrimitive
        end

        class JavaShort < JavaPrimitive
        end

        class JavaChar < JavaPrimitive
        end

        class JavaInteger < JavaPrimitive
        end

        class JavaLong < JavaPrimitive
        end

        class JavaFloat < JavaPrimitive
        end

        class JavaDouble < JavaPrimitive
        end

        class JavaBase
          attr_accessor :type
          attr_accessor :desc
        end

        class JavaObject < JavaBase
          attr_accessor :fields

          def initialize(type, fields)
            @type = type
            @fields = fields
          end
        end

        class JavaCustomObject < JavaObject
          def initialize(type, fields, desc)
            super(type, fields)
            @desc = desc
          end
        end

        class JavaProxy < JavaObject
          def initialize(intf, handler)
            super('', { 'h' => handler })
            @desc = {
              'proxy' => true,
              'serialVersion' => 0,
              'hasWriteObject' => false,
              'superType' => 'Ljava/lang/reflect/Proxy;',
              'interfaces' => intf
            }
        end
        end

        class JavaClass < JavaBase
          def initialize(type)
            @type = type
          end
        end

        class ObjectStreamClass < JavaBase
          def initialize(type)
            @type = type
          end
        end

        class JavaArray < JavaBase
          attr_accessor :componentType
          attr_accessor :values

          def initialize(componentType, values)
            @type = '[' + componentType
            @componentType = componentType
            @values = values
          end

          def primitive
            code = @componentType[0]
            code != 'L' && code != '['
          end
          end

        class JavaEnum < JavaBase
          attr_accessor :name

          def initialize(type, name)
            @name = name
            @type = type
          end
        end
      end
    end
  end
end

