# -*- coding: binary -*-

require 'rex/java/serialization'
require 'rex/java/serialization/metamodel'

###
# Utilities for creating various serialization gadgets
# 
# This module contains various generators producing 
# serializable models for various published deserialization 
# gadgets.
#
# This mostly reflects the gadgets published in ysoserial
# (https://github.com/frohoff/ysoserial/).
###
module Rex
  module Java
    module Serialization
      module Payloads
        Model = Rex::Java::Serialization::Metamodel

        autoload :Util, 'rex/java/serialization/payloads/util'

        autoload :Atomikos, 'rex/java/serialization/payloads/atomikos'
        autoload :Beanshell, 'rex/java/serialization/payloads/beanshell'
        autoload :Beanutils, 'rex/java/serialization/payloads/beanutils'
        autoload :C3P0, 'rex/java/serialization/payloads/c3p0'
        autoload :Collections, 'rex/java/serialization/payloads/collections'
        autoload :DOS, 'rex/java/serialization/payloads/dos'
        autoload :Groovy, 'rex/java/serialization/payloads/groovy'
        autoload :Hibernate, 'rex/java/serialization/payloads/hibernate'
        autoload :JBoss, 'rex/java/serialization/payloads/jboss'
        autoload :JRMP, 'rex/java/serialization/payloads/jrmp'
        autoload :JSON, 'rex/java/serialization/payloads/json'
        autoload :Jython, 'rex/java/serialization/payloads/jython'
        autoload :Probe, 'rex/java/serialization/payloads/probe'
        autoload :Rhino, 'rex/java/serialization/payloads/rhino'
        autoload :ROME, 'rex/java/serialization/payloads/rome'
        autoload :Spring, 'rex/java/serialization/payloads/spring'
        autoload :Templates, 'rex/java/serialization/payloads/templates'
        autoload :URL, 'rex/java/serialization/payloads/url'
        autoload :Vaadin, 'rex/java/serialization/payloads/vaadin'
      end
    end
  end
end

