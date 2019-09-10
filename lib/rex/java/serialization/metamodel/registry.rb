# -*- coding: binary -*-

require 'rex/java'
require 'json'

###
# Descriptor registry
#
# Descriptors can be loaded from JSON, format is as follows:
# list of descriptor objects
# [ 
#   {
#     typeString" : "Lmy/pkg/Type;",
#     "serialVersion" : 7373984972572414691,
#     # list of field descriptors
#     "fields" : [ {
#       "name" : "field_name",
#       "typeString" : "<type>"
#     } ],
#     "superType" : "Lx/y/z/Type;" (if not java.lang.Object)
#     "hasWriteObject" : true, (if type has custom serialization)
#     "hasReadObject" : true, (if type has custom deserialization)
#     "externalizable" : true, (if type is externalizable)
#     "enum" : true, (if type is an Enum class)
#   }
# ]
#
# All type specifications/signatures are in Java internal format:
# https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html#jvms-4.3
#
# A generateor that processes Java classes and output the descriptors
# is available in contrib/sermodelgen/.
#
# Custom serialization/deserialization code goes into a ObjectHandler 
# object. These are currently required to go into the handlers/ directory,
# and be named accordingly:
# - type name as in internal signature format, my/pkg/Type
# - replace / and $ (inner types) with underscores -> my_pkg_Type
# - append .rb
#
# The actual class name needs to be capitalized and extends
# Rex::Java::Serialization::Metamodel::ObjectHandlers.
###
module Rex
  module Java
    module Serialization
      module Metamodel

        class ObjectHandlers
          def writeObject(_stream, _obj, _desc)
            raise NotImplementedError, 'writeObject: ' + to_s
          end

          def writeExternal(_stream, _obj, _desc)
            raise NotImplementedError, 'writeExternal: ' + to_s
          end

          def readObject(_stream, _desc)
            raise NotImplementedError, 'readObject: ' + to_s
          end
        end



        class Registry
          attr_accessor :loaded

          def initialize(base: nil, clone: nil)
            base = Rex::Java.datadir if base.nil?
            @types = {}
            @handlers = {}
            @loaded = []
            @base = base

            # primitives
            Rex::Java::Serialization::PRIMITIVE_TYPE_CODES.keys.each do |t|
              @types[t] = { 'typeString' => t }
            end

            unless clone.nil?
              @base = clone.instance_variable_get :@base
              @loaded = (clone.instance_variable_get :@loaded).dup
              @handlers = (clone.instance_variable_get :@handlers).dup
              @types = (clone.instance_variable_get :@types).dup
            end
          end

          def load(filename)
            @loaded.push(filename)
            filename = File.expand_path(filename, @base)
            model = JSON.parse(File.read(filename))
            model.each do |entry|
              ts = entry.fetch('typeString')
              @types[ts] = entry
            end
          end

          def dup
            Registry.new(clone: self)
          end

          def register(name, info)
            ts = 'L' + name.tr('.', '/') + ';'
            info['typeString'] = ts 
            @types[ts] = info
          end

          def getHandler(ts)
            raise ClassNotFoundError, ts if ts[0] != 'L' || ts[-1] != ';'
            handlerName = ts[1..-2].tr('/', '_').tr('$', '_')
            begin 
              require_relative 'handlers/' + handlerName + '.rb'
            rescue LoadError
              raise "Missing handler for " + ts
            end
            klass = Object.const_get(handlerName[0].upcase + handlerName[1..-1])
            klass.new
          end

          def writeObject(stream, obj, desc)
            ts = desc.fetch('typeString')
            getHandler(ts).writeObject(stream, obj, desc)
          end

          def writeExternal(stream, obj, desc)
            ts = desc.fetch('typeString')
            getHandler(ts).writeExternal(stream, obj, desc)
          end

          def getDescriptor(type)
            return @types[type] unless @types[type].nil?

            return nil if type == '' || type[0] != '['

            ctype = type[1..-1]
            compDesc = getDescriptor(ctype)

            raise ClassNotFoundError, ctype if compDesc.nil?

            desc = {
              'name' => type,
              'typeString' => type
            }
            @types[type] = desc
            desc
          end

          def putDescriptor(type, desc)
            @types[type] = desc
          end
        end
      end
    end
  end
end
