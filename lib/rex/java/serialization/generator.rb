# -*- coding: binary -*-
require 'rex/java/serialization'

###
# This module tries to automatically create a payload suitable 
# for a previously probed target.
#
#
###
module Rex
  module Java
    module Serialization
      module Generator
        autoload :BuiltinGadgets, 'rex/java/serialization/generator/base'
        autoload :GeneratorConfig, 'rex/java/serialization/generator/base'
        autoload :Templates, 'rex/java/serialization/generator/templates'
      end
    end
  end
end

